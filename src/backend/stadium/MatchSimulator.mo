import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Stadium "../Stadium";
import Player "../Player";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Random "mo:base/Random";
import Int "mo:base/Int";
import Int32 "mo:base/Int32";
import Prelude "mo:base/Prelude";
import Nat8 "mo:base/Nat8";

module {
    type PlayerState = Stadium.PlayerState;
    type Event = Stadium.Event;
    type BaseInfo = Stadium.BaseInfo;
    type MatchState = Stadium.MatchState;
    type TeamState = Stadium.TeamState;
    type TeamLineup = Stadium.TeamLineup;
    type InProgressMatchState = Stadium.InProgressMatchState;
    type PlayerWithId = Player.PlayerWithId;
    type PlayerPosition = Stadium.PlayerPosition;
    type PlayerPositionDefense = Stadium.PlayerPositionDefense;
    type TeamId = Stadium.TeamId;
    type PlayerSkills = Player.PlayerSkills;

    type MutableTeamState = {
        var score : Int;
        var battingOrder : Buffer.Buffer<Nat32>;
        var substitutes : Buffer.Buffer<Nat32>;
        var currentBatterIndex : Nat;
    };

    type MutableMatchState = {
        var offenseTeam : TeamId;
        var team1 : MutableTeamState;
        var team2 : MutableTeamState;
        var players : Trie.Trie<Nat32, MutablePlayerState>;
        var events : Buffer.Buffer<Event>;
        var positions : Trie.Trie<PlayerPosition, Nat32>;
        var round : Nat;
        var outs : Nat;
        var strikes : Nat;
    };

    type MutablePlayerSkills = {
        var batting : Int;
        var throwing : Int;
    };

    type MutablePlayerState = {
        var name : Text;
        var teamId : TeamId;
        var energy : Int;
        var condition : Player.PlayerCondition;
        var skills : MutablePlayerSkills;
        var preferredPosition : PlayerPositionDefense;
    };

    type HitLocation = {
        #outOfPark;
        #firstBase;
        #secondBase;
        #thirdBase;
        #shortStop;
        #pitcher;
        #leftField;
        #centerField;
        #rightField;
    };

    public type TeamInitData = {
        id : Principal;
        lineup : ?TeamLineup;
        players : [PlayerWithId];
    };

    public func initState(team1 : TeamInitData, team2 : TeamInitData, team1StartOffense : Bool) : MatchState {

        let (team1Lineup, team2Lineup) : (TeamLineup, TeamLineup) = switch (team1.lineup, team2.lineup) {
            case (null, null) return #completed(#allAbsent);
            case (null, ?_) return #completed(#absentTeam(#team1));
            case (?_, null) return #completed(#absentTeam(#team2));
            case (?team1Lineup, ?team2Lineup)(team1Lineup, team2Lineup);
        };
        var players = Trie.empty<Nat32, PlayerState>();
        let addPlayer = func(player : PlayerWithId, teamId : TeamId) {
            let playerState : PlayerState = {
                name = player.name;
                teamId = teamId;
                energy = player.energy;
                condition = player.condition;
                skills = player.skills;
                preferredPosition =;
            };
            let key = {
                key = player.id;
                hash = player.id;
            };
            let (newPlayers, _) = Trie.put<Nat32, PlayerState>(players, key, Nat32.equal, playerState);
            players := newPlayers;
        };
        let team1Positions = getPositionMap(team1Lineup);
        for (player in team1.players.vals()) {
            addPlayer(player, #team1);
        };
        let team2Positions = getPositionMap(team2Lineup);
        for (player in team2.players.vals()) {
            addPlayer(player, #team2);
        };
        let (offenseLineup, defenseLineup) = if (team1StartOffense) {
            (team1Lineup, team2Lineup);
        } else {
            (team2Lineup, team1Lineup);
        };
        let positions = resetPositions(players);
        #inProgress({
            offenseTeam = if (team1StartOffense) #team1 else #team2;
            team1 = {
                score = 0;
                battingOrder = team1Lineup.battingOrder;
                currentBatterIndex = 0;
                substitutes = team2Lineup.substitutes;
            };
            team2 = {
                score = 0;
                battingOrder = team2Lineup.battingOrder;
                currentBatterIndex = 0;
                substitutes = team2Lineup.substitutes;
            };
            events = [];
            players = players;
            positions = positions;
            round = 0;
            outs = 0;
            strikes = 0;
        });
    };

    private func resetPositions(defenseLineup : TeamLineup) : Trie.Trie<PlayerPosition, Nat32> {
        var positions = Trie.empty<PlayerPosition, Nat32>();
        let setPosition = func(position : PlayerPosition, playerId : Nat32) : () {
            let key : Trie.Key<PlayerPosition> = {
                key = position;
                hash = Stadium.hashPlayerPosition(position);
            };
            let (newMap, _) = Trie.put<PlayerPosition, Nat32>(positions, key, Stadium.equalPlayerPosition, playerId);
            positions := newMap;
        };

        setPosition(#pitcher, defenseLineup.pitcher);
        setPosition(#catcher, defenseLineup.catcher);
        setPosition(#firstBase, defenseLineup.firstBase);
        setPosition(#secondBase, defenseLineup.secondBase);
        setPosition(#thirdBase, defenseLineup.thirdBase);
        setPosition(#shortStop, defenseLineup.shortStop);
        setPosition(#leftField, defenseLineup.leftField);
        setPosition(#centerField, defenseLineup.centerField);
        setPosition(#rightField, defenseLineup.rightField);

        positions;
    };

    public func tick(state : InProgressMatchState, random : Random.Finite) : MatchState {
        let simulation = MatchSimulation(state, random);

        pitch(simulation);

        simulation.buildState();
    };

    private func pitch(simulation : MatchSimulation) {
        let atBatPlayerId = switch (simulation.getPlayerAtPosition(#atBat)) {
            case (null) sendNextPlayerToBat(simulation);
            case (?playerId) playerId;
        };
        let atBatPlayer = simulation.getPlayer(atBatPlayerId);
        let pitcherId = switch (simulation.getPlayerAtPosition(#pitcher)) {
            case (null) Debug.trap("No pitcher found"); // TODO
            case (?playerId) playerId;
        };
        let pitcher = simulation.getPlayer(pitcherId);
        let pitchRoll = simulation.randomInt(0, 10) + pitcher.skills.throwing;
        let batterRoll = simulation.randomInt(0, 10) + atBatPlayer.skills.batting;
        let batterNetScore = batterRoll - pitchRoll;
        if (batterNetScore < 0) {
            simulation.addEvent({
                description = "Strike"; // TODO # Nat.toText(simulation.strike + 1);
                effect = #addStrike;
            });
        } else {
            hit(simulation, atBatPlayerId, batterNetScore);
        };
    };

    private func hit(simulation : MatchSimulation, atBatPlayerId : Nat32, batterNetScore : Int) {
        let precisionRoll = simulation.randomInt(-2, 2) + batterNetScore;
        if (precisionRoll < 0) {
            simulation.addEvent({
                description = "Foul";
                effect = #none;
            });
        } else {
            let player = simulation.getPlayer(atBatPlayerId);
            let hitLocation = if (precisionRoll > 10) {
                simulation.addEvent({
                    description = player.name # " hits a homerun!";
                    effect = #none;
                });
                #outOfPark;
            } else {
                let (location, name) = switch (simulation.randomInt(0, 7)) {
                    case (0)(#firstBase, "first base");
                    case (1)(#secondBase, "second base");
                    case (2)(#thirdBase, "third base");
                    case (3)(#shortStop, "short stop");
                    case (4)(#pitcher, "pitcher");
                    case (5)(#leftField, "left field");
                    case (6)(#centerField, "center field");
                    case (7)(#rightField, "right field");
                    case (_) Prelude.unreachable();
                };
                simulation.addEvent({
                    description = player.name # " hits the ball to " # name;
                    effect = #none;
                });
                location;
            };
            run(simulation, atBatPlayerId, hitLocation);
        };
    };

    private func run(simulation : MatchSimulation, playerId : Nat32, hitLocation : HitLocation) {
        dfasdf;
    };

    private func sendNextPlayerToBat(simulation : MatchSimulation) : Nat32 {
        let nextBatterId = simulation.incrementBattingOrder();
        let nextBatter = simulation.getPlayer(nextBatterId);
        simulation.addEvent({
            description = "Player " # nextBatter.name # " is up to bat";
            effect = #movePlayerOffense({
                playerId = nextBatterId;
                position = ? #atBat;
            });
        });
        nextBatterId;
    };
    // TODO handle limited entropy from random by refetching entropy from the chain
    class MatchSimulation(initialState : InProgressMatchState, random : Random.Finite) {

        private func toMutableSkills(skills : PlayerSkills) : MutablePlayerSkills {
            {
                var batting = skills.batting;
                var throwing = skills.throwing;
            };
        };

        private func toMutableState(state : InProgressMatchState) : MutableMatchState {
            let mutablePlayers = Trie.mapFilter(
                state.players,
                func(id : Nat32, player : PlayerState) : ?MutablePlayerState {
                    ?{
                        var name = player.name;
                        var teamId = player.teamId;
                        var energy = player.energy;
                        var condition = player.condition;
                        var skills = toMutableSkills(player.skills);
                        var prefferedPosition = player.prefferedPosition;
                    };
                },
            );
            {
                var offenseTeam = state.offenseTeam;
                var team1 = toMutableTeam(initialState.team1);
                var team2 = toMutableTeam(initialState.team2);
                var players = mutablePlayers;
                var events = Buffer.fromArray(initialState.events);
                var positions = initialState.positions;
                var round = initialState.round;
                var outs = initialState.outs;
                var strikes = initialState.strikes;
            };
        };

        private func toMutableTeam(team : TeamState) : MutableTeamState {
            {
                var score = team.score;
                var battingOrder = Buffer.fromArray<Nat32>(team.battingOrder);
                var currentBatterIndex = team.currentBatterIndex;
                var substitutes = Buffer.fromArray<Nat32>(team.substitutes);
            };
        };

        let state : MutableMatchState = toMutableState(initialState);

        public func buildState() : MatchState {
            let players = Trie.mapFilter(
                state.players,
                func(id : Nat32, player : MutablePlayerState) : ?PlayerState {
                    ?{
                        name = player.name;
                        teamId = player.teamId;
                        energy = player.energy;
                        condition = player.condition;
                        skills = {
                            batting = player.skills.batting;
                            throwing = player.skills.throwing;
                        };
                    };
                },
            );
            #inProgress({
                offenseTeam = state.offenseTeam;
                team1 = {
                    score = state.team1.score;
                    battingOrder = Buffer.toArray(state.team1.battingOrder);
                    currentBatterIndex = state.team1.currentBatterIndex;
                    substitutes = Buffer.toArray(state.team1.substitutes);
                };
                team2 = {
                    score = state.team2.score;
                    battingOrder = Buffer.toArray(state.team2.battingOrder);
                    currentBatterIndex = state.team2.currentBatterIndex;
                    substitutes = Buffer.toArray(state.team2.substitutes);
                };
                events = Buffer.toArray(state.events);
                players = players;
                positions = state.positions;
                round = state.round;
                outs = state.outs;
                strikes = state.strikes;
            });
        };

        public func randomInt(min : Int, max : Int) : Int {
            let range : Nat = Int.abs(max - min) + 1;
            // TODO do better?
            var result : Nat = 0;
            var log2 : Nat = range - 1;
            while (log2 > 0) {
                log2 := log2 / 2;
                result += 1;
            };
            let ?randVal = random.range(Nat8.fromNat(log2)) else Debug.trap("No more entropy"); // TODO
            min + randVal % range;
        };

        public func getPlayerAtPosition(position : PlayerPosition) : ?Nat32 {
            let key : Trie.Key<PlayerPosition> = {
                key = position;
                hash = Stadium.hashPlayerPosition(position);
            };
            Trie.get(state.positions, key, Stadium.equalPlayerPosition);
        };

        public func incrementBattingOrder() : Nat32 {
            let team = switch (state.offenseTeam) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
            team.currentBatterIndex += 1;
            if (team.currentBatterIndex >= team.battingOrder.size()) {
                team.currentBatterIndex := 0;
            };
            team.battingOrder.get(team.currentBatterIndex);
        };

        public func getPlayer(playerId : Nat32) : MutablePlayerState {
            let key = {
                key = playerId;
                hash = playerId;
            };
            let ?player = Trie.get(state.players, key, Nat32.equal) else Debug.trap("Player not found: " # Nat32.toText(playerId));
            player;
        };

        public func addEvent(event : Event) : () {
            state.events.add(event);
            switch (event.effect) {
                case (#subPlayer({ playerOutId })) {
                    let playerOut = getPlayer(playerOutId);
                    let team = switch (playerOut.teamId) {
                        case (#team1) state.team1;
                        case (#team2) state.team2;
                    };

                    // TODO improve sub logic such as dedicated field positions
                    // Swap sub for player, if any left
                    switch (team.substitutes.removeLast()) {
                        case (null) {
                            addEvent({
                                description = playerOut.name # " has run out of energy but there is no substitute available";
                                effect = #none;
                            });
                        };
                        case (?subPlayerId) {
                            var found = false;
                            // Swap the players in the batting order
                            team.battingOrder := Buffer.map(
                                team.battingOrder,
                                func(playerId : Nat32) : Nat32 {
                                    if (playerId == playerOutId) {
                                        found := true;
                                        // Change the player in the batting order from out to in
                                        return subPlayerId;
                                    };
                                    playerId;
                                },
                            );
                            if (not found) {
                                Debug.trap("Player " # Nat32.toText(playerOutId) # " is not in the batting order");
                            };

                            // Physically swap the players
                            let previousPosition = movePlayer(playerOutId, null);
                            let _ = movePlayer(subPlayerId, previousPosition);
                        };
                    };

                };
                case (#increaseScore({ teamId; amount })) {
                    let team = switch (teamId) {
                        case (#team1) state.team1;
                        case (#team2) state.team2;
                    };
                    team.score := team.score + amount;
                };
                case (#setPlayerCondition({ playerId; condition })) {
                    let player = getPlayer(playerId);
                    player.condition := condition;
                    let substituteOut = switch (condition) {
                        case (#ok) false;
                        case (#injured(i)) true;
                        case (#dead) true;
                    };
                    if (substituteOut) {
                        addEvent({
                            description = player.name # " has been substituted out due to condition";
                            effect = #subPlayer({
                                playerOutId = playerId;
                            });
                        });
                    };
                };
                case (#increaseEnergy({ playerId; amount })) {
                    let player = getPlayer(playerId);
                    player.energy := player.energy + amount;
                    if (player.energy <= 0) {
                        addEvent({
                            description = player.name # " has run out of energy and needs to be substituted out";
                            effect = #subPlayer({
                                playerOutId = playerId;
                            });
                        });
                    };
                };
                case (#movePlayerOffense(movePlayerOffense)) {
                    // TODO what if other player is already at that position?
                    let _ = movePlayer(movePlayerOffense.playerId, movePlayerOffense.position);
                };
                case (#addStrike) {
                    state.strikes += 1;
                    if (state.strikes >= 3) {
                        let ?playerId = getPlayerAtPosition(#atBat) else Debug.trap("No batter found");
                        let _ = movePlayer(playerId, null);
                        addEvent({
                            description = "Strikeout";
                            effect = #addOut;
                        });
                    };
                };
                case (#addOut) {
                    state.outs += 1;
                    if (state.outs >= 3) {
                        addEvent({
                            description = "Round over";
                            effect = #endRound;
                        });
                    };
                };
                case (#endRound) {
                    state.outs := 0;
                    state.round += 1;
                    state.offenseTeam := switch (state.offenseTeam) {
                        case (#team1) #team2;
                        case (#team2) #team1;
                    };
                    let defenseTeam = switch (state.offenseTeam) {
                        case (#team1) state.team2;
                        case (#team2) state.team1;
                    };
                    state.positions := resetPositions(defenseTeam);
                };
                case (#none) {
                    // Skip
                };
            };
        };

        private func movePlayer(playerId : Nat32, newPosition : ?PlayerPosition) : ?PlayerPosition {
            let team = switch (state.offenseTeam) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
            var previousPosition : ?PlayerPosition = null;
            // Remove player from field
            for ((position, id) in Trie.iter(state.positions)) {
                if (id == playerId) {
                    previousPosition := ?position;
                    let key = {
                        key = position;
                        hash = Stadium.hashPlayerPosition(position);
                    };
                    let (newPositions, _) = Trie.remove(state.positions, key, Stadium.equalPlayerPosition);
                    state.positions := newPositions;
                };
            };

            switch (newPosition) {
                case (null) {
                    // Skip. Already removed from the field
                };
                case (?p) {
                    // Add player to field in the new position
                    let key = {
                        key = p;
                        hash = Stadium.hashPlayerPosition(p);
                    };
                    let (newPositions, _) = Trie.put(state.positions, key, Stadium.equalPlayerPosition, playerId);
                    state.positions := newPositions;
                };
            };
            previousPosition;
        };

    };
};
