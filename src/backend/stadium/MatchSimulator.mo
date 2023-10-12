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
import Iter "mo:base/Iter";
import TrieMap "mo:base/TrieMap";
import Float "mo:base/Float";
import RandomUtil "../RandomUtil";
import StadiumUtil "StadiumUtil";

module {
    type PlayerState = Stadium.PlayerState;
    type Event = Stadium.Event;
    type MatchState = Stadium.MatchState;
    type TeamState = Stadium.TeamState;
    type MatchOptions = Stadium.MatchOptions;
    type InProgressMatchState = Stadium.InProgressMatchState;
    type PlayerWithId = Player.PlayerWithId;
    type FieldPosition = Player.FieldPosition;
    type Base = Player.Base;
    type TeamId = Stadium.TeamId;
    type PlayerSkills = Player.PlayerSkills;
    type PlayerId = Nat32;

    type MutableTeamState = {
        var score : Int;
        offeringId : Nat32;
    };

    type MutableMatchState = {
        var offenseTeamId : TeamId;
        var team1 : MutableTeamState;
        var team2 : MutableTeamState;
        specialRuleId : ?Nat32;
        var players : TrieMap.TrieMap<PlayerId, MutablePlayerState>;
        var events : Buffer.Buffer<Event>;
        var batter : ?PlayerId;
        var positions : TrieMap.TrieMap<FieldPosition, PlayerId>;
        var bases : TrieMap.TrieMap<Base, PlayerId>;
        var round : Nat;
        var outs : Nat;
        var strikes : Nat;
    };

    type MutablePlayerSkills = {
        var battingPower : Nat;
        var battingAccuracy : Nat;
        var throwingAccuracy : Nat;
        var throwingPower : Nat;
        var catching : Nat;
        var health : Nat;
        var defense : Nat;
        var piety : Nat;
    };

    type MutablePlayerState = {
        var name : Text;
        var teamId : TeamId;
        var condition : Player.PlayerCondition;
        var skills : MutablePlayerSkills;
        var position : FieldPosition;
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
        offeringId : Nat32;
        specialRuleVotes : Trie.Trie<Nat32, Nat>;
        players : [PlayerWithId];
    };

    public func initState(
        specialRules : [Stadium.SpecialRule],
        team1 : TeamInitData,
        team2 : TeamInitData,
        team1StartOffense : Bool,
    ) : MatchState {
        var players = Trie.empty<PlayerId, PlayerState>();
        let addPlayer = func(player : PlayerWithId, teamId : TeamId) {
            let playerState : PlayerState = {
                name = player.name;
                teamId = teamId;
                condition = player.condition;
                skills = player.skills;
                position = player.position;
            };
            let key = {
                key = player.id;
                hash = player.id;
            };
            let (newPlayers, _) = Trie.put<PlayerId, PlayerState>(players, key, Nat32.equal, playerState);
            players := newPlayers;
        };
        for (player in team1.players.vals()) {
            addPlayer(player, #team1);
        };
        for (player in team2.players.vals()) {
            addPlayer(player, #team2);
        };
        let specialRuleId = calculateSpecialRule(specialRules, team1.specialRuleVotes, team2.specialRuleVotes);

        #inProgress({
            offenseTeamId = if (team1StartOffense) #team1 else #team2;
            team1 = {
                score = 0;
                offeringId = team1.offeringId;
            };
            team2 = {
                score = 0;
                offeringId = team2.offeringId;
            };
            specialRuleId = specialRuleId;
            events = [];
            players = players;
            batter = null;
            positions = Trie.empty();
            bases = Trie.empty();
            round = 0;
            outs = 0;
            strikes = 0;
        });
    };

    private func calculateSpecialRule(
        specialRules : [Stadium.SpecialRule],
        team1Votes : Trie.Trie<Nat32, Nat>,
        team2Votes : Trie.Trie<Nat32, Nat>,
    ) : ?Nat32 {
        let team1NormalizedVotes = normalizeVotes(team1Votes);
        let team2NormalizedVotes = normalizeVotes(team2Votes);
        var winningRule : ?(Nat32, Float) = null;
        // TODO rule index vs id
        var id : Nat32 = 0;
        for (rule in Array.vals(specialRules)) {
            let key = {
                key = id;
                hash = id;
            };
            let team1Vote : Float = switch (Trie.get(team1NormalizedVotes, key, Nat32.equal)) {
                case (null) 0;
                case (?v) v;
            };
            let team2Vote : Float = switch (Trie.get(team2NormalizedVotes, key, Nat32.equal)) {
                case (null) 0;
                case (?v) v;
            };
            let voteCount = team1Vote + team2Vote;
            switch (winningRule) {
                case (null) winningRule := ?(id, voteCount);
                case (?(id, c)) {
                    if (voteCount > c) {
                        winningRule := ?(id, voteCount);
                    };
                    // TODO what if tie?
                };
            };
            id += 1;
        };
        switch (winningRule) {
            case (null) null;
            case (?(id, voteCount)) ?id;
        };
    };

    private func normalizeVotes(votes : Trie.Trie<Nat32, Nat>) : Trie.Trie<Nat32, Float> {
        var totalVotes = 0;
        for ((id, voteCount) in Trie.iter(votes)) {
            totalVotes += voteCount;
        };
        if (totalVotes == 0) {
            return Trie.empty();
        };
        Trie.mapFilter<Nat32, Nat, Float>(
            votes,
            func(voteCount : (Nat32, Nat)) : ?Float = ?(Float.fromInt(voteCount.1) / Float.fromInt(totalVotes)),
        );
    };

    public func tick(state : InProgressMatchState, random : Random.Finite) : MatchState {
        let simulation = MatchSimulation(state, random);

        pitch(simulation);

        simulation.buildState();
    };

    private func pitch(simulation : MatchSimulation) {
        let atBatPlayerId = switch (simulation.getPlayerAtBase(#homeBase)) {
            case (null) sendNextPlayerToBat(simulation);
            case (?playerId) playerId;
        };
        let atBatPlayer = simulation.getPlayer(atBatPlayerId);
        let pitcherId = switch (simulation.getPlayerAtPosition(#pitcher)) {
            case (null) Debug.trap("No pitcher found"); // TODO
            case (?playerId) playerId;
        };
        let pitcher = simulation.getPlayer(pitcherId);
        let pitchRoll = simulation.randomInt(0, 10) + pitcher.skills.throwingAccuracy + pitcher.skills.throwingPower;
        let batterRoll = simulation.randomInt(0, 10) + atBatPlayer.skills.battingAccuracy + atBatPlayer.skills.battingPower;
        let batterNetScore = batterRoll - pitchRoll;
        if (batterNetScore < 0) {
            simulation.addEvent({
                description = "Strike"; // TODO # Nat.toText(simulation.strike + 1);
                effect = #addStrike({
                    playerId = atBatPlayerId;
                });
            });
        } else {
            hit(simulation, atBatPlayerId, batterNetScore);
        };
    };

    private func hit(simulation : MatchSimulation, atBatPlayerId : PlayerId, batterNetScore : Int) {
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

    private func run(simulation : MatchSimulation, playerId : PlayerId, hitLocation : HitLocation) {
        switch (hitLocation) {
            case (#outOfPark) {
                simulation.addEvent({
                    description = "Home run!";
                    effect = #none;
                });
            };
            case (#firstBase) tryCatch(simulation, playerId, #firstBase);
            case (#secondBase) tryCatch(simulation, playerId, #secondBase);
            case (#thirdBase) tryCatch(simulation, playerId, #thirdBase);
            case (#shortStop) tryCatch(simulation, playerId, #shortStop);
            case (#pitcher) tryCatch(simulation, playerId, #pitcher);
            case (#leftField) tryCatch(simulation, playerId, #leftField);
            case (#centerField) tryCatch(simulation, playerId, #centerField);
            case (#rightField) tryCatch(simulation, playerId, #rightField);
        };

    };

    private func tryCatch(simulation : MatchSimulation, battingPlayerId : PlayerId, catchLocation : FieldPosition) {
        let catchingPlayerId = switch (simulation.getPlayerAtPosition(catchLocation)) {
            case (null) {
                // TODO handle someone from different location catching
                Debug.trap("No player found at " # Player.toTextFieldPosition(catchLocation));
            };
            case (?playerId) playerId;
        };
        let catchingPlayer = simulation.getPlayer(catchingPlayerId);
        let catchRoll = simulation.randomInt(-10, 10) + catchingPlayer.skills.catching;
        if (catchRoll <= 0) {
            simulation.addEvent({
                description = catchingPlayer.name # " misses the catch";
                effect = #none;
            });
            let canPickUpInTime = simulation.randomInt(0, 10) + catchingPlayer.skills.catching;
            if (canPickUpInTime > 0) {
                simulation.addEvent({
                    description = catchingPlayer.name # " picks up the ball";
                    effect = #none;
                });
                // TODO against dodge/speed skill of runner
                let throwRoll = simulation.randomInt(-10, 10) + catchingPlayer.skills.throwingAccuracy;
                if (throwRoll <= 0) {
                    simulation.addEvent({
                        description = catchingPlayer.name # " misses the throw";
                        effect = #none;
                    });
                    simulation.addEvent({
                        description = "Runner is safe";
                        effect = #movePlayerToBase({
                            playerId = battingPlayerId;
                            base = ? #firstBase;
                        });
                    });
                } else {
                    simulation.addEvent({
                        description = catchingPlayer.name # " throws the ball and hits the player";
                        // TODO damage player?
                        effect = #addOut({
                            playerId = battingPlayerId;
                        });
                    });
                };
            } else {
                simulation.addEvent({
                    description = catchingPlayer.name # " cannot pick up the ball in time";
                    effect = #none;
                });
            };
        } else {
            simulation.addEvent({
                description = catchingPlayer.name # " catches the ball";
                effect = #addOut({
                    playerId = battingPlayerId;
                });
            });
        };
    };

    private func sendNextPlayerToBat(simulation : MatchSimulation) : PlayerId {
        let nextBatterId = simulation.getNextBatter();
        let nextBatter = simulation.getPlayer(nextBatterId);
        simulation.addEvent({
            description = "Player " # nextBatter.name # " is up to bat";
            effect = #movePlayerToBase({
                playerId = nextBatterId;
                base = ? #homeBase;
            });
        });
        nextBatterId;
    };
    // TODO handle limited entropy from random by refetching entropy from the chain
    class MatchSimulation(initialState : InProgressMatchState, random : Random.Finite) {

        private func toMutableSkills(skills : PlayerSkills) : MutablePlayerSkills {
            {
                var battingPower = skills.battingPower;
                var battingAccuracy = skills.battingAccuracy;
                var throwingPower = skills.throwingPower;
                var throwingAccuracy = skills.throwingAccuracy;
                var catching = skills.catching;
                var health = skills.health;
                var defense = skills.defense;
                var piety = skills.piety;
            };
        };

        private func toMutableState(state : InProgressMatchState) : MutableMatchState {
            let players = StadiumUtil.trieToMap<PlayerId, PlayerState, MutablePlayerState>(
                state.players,
                Nat32.equal,
                func(h : Nat32) : Nat32 = h,
                func(player : PlayerState) : MutablePlayerState {
                    {
                        var name = player.name;
                        var teamId = player.teamId;
                        var condition = player.condition;
                        var skills = toMutableSkills(player.skills);
                        var position = player.position;
                    };
                },
            );
            let positions = StadiumUtil.trieToMap<FieldPosition, PlayerId, PlayerId>(
                state.positions,
                Player.equalFieldPosition,
                Player.hashFieldPosition,
                func(playerId : PlayerId) : PlayerId = playerId,
            );
            let bases = StadiumUtil.trieToMap<Base, PlayerId, PlayerId>(
                state.bases,
                Player.equalBase,
                Player.hashBase,
                func(playerId : PlayerId) : PlayerId = playerId,
            );
            {
                var offenseTeamId = state.offenseTeamId;
                var team1 = toMutableTeam(initialState.team1);
                var team2 = toMutableTeam(initialState.team2);
                var players = players;
                specialRuleId = state.specialRuleId;
                var positions = positions;
                var batter = state.batter;
                var events = Buffer.fromArray(initialState.events);
                var bases = bases;
                var round = initialState.round;
                var outs = initialState.outs;
                var strikes = initialState.strikes;
            };
        };

        private func toMutableTeam(team : TeamState) : MutableTeamState {
            {
                var score = team.score;
                offeringId = team.offeringId;
            };
        };

        let state : MutableMatchState = toMutableState(initialState);

        public func buildState() : MatchState {
            let players = StadiumUtil.trieMapToTrie(
                state.players,
                Nat32.equal,
                func(h : Nat32) : Nat32 = h,
                func(player : MutablePlayerState) : PlayerState {
                    {
                        name = player.name;
                        teamId = player.teamId;
                        condition = player.condition;
                        position = player.position;
                        skills = {
                            battingPower = player.skills.battingPower;
                            battingAccuracy = player.skills.battingAccuracy;
                            throwingPower = player.skills.throwingPower;
                            throwingAccuracy = player.skills.throwingAccuracy;
                            catching = player.skills.catching;
                            health = player.skills.health;
                            defense = player.skills.defense;
                            piety = player.skills.piety;
                        };
                    };
                },
            );

            let positions = StadiumUtil.trieMapToTrie<FieldPosition, PlayerId, PlayerId>(
                state.positions,
                Player.equalFieldPosition,
                Player.hashFieldPosition,
                func(playerId : PlayerId) : PlayerId = playerId,
            );
            let bases = StadiumUtil.trieMapToTrie<Base, PlayerId, PlayerId>(
                state.bases,
                Player.equalBase,
                Player.hashBase,
                func(playerId : PlayerId) : PlayerId = playerId,
            );

            #inProgress({
                offenseTeamId = state.offenseTeamId;
                team1 = {
                    score = state.team1.score;
                    offeringId = state.team1.offeringId;
                };
                team2 = {
                    score = state.team2.score;
                    offeringId = state.team2.offeringId;
                };
                specialRuleId = state.specialRuleId;
                events = Buffer.toArray(state.events);
                players = players;
                batter = state.batter;
                positions = positions;
                bases = bases;
                round = state.round;
                outs = state.outs;
                strikes = state.strikes;
            });
        };
        public func getPlayerAtPosition(position : FieldPosition) : ?Nat32 {
            state.positions.get(position);
        };

        public func getPlayerAtBase(base : Base) : ?Nat32 {
            state.bases.get(base);
        };

        public func randomInt(min : Int, max : Int) : Int {
            let ?v = RandomUtil.randomInt(random, min, max) else Debug.trap("Random ran out of entropy"); // TODO
            v;
        };
        public func randomNat(min : Nat, max : Nat) : Nat {
            let ?v = RandomUtil.randomNat(random, min, max) else Debug.trap("Random ran out of entropy"); // TODO
            v;
        };

        public func getNextBatter() : PlayerId {
            // get random player
            let availablePlayers = getAvailablePlayers(?state.offenseTeamId, null);
            let randomIndex = randomNat(0, availablePlayers.size());
            availablePlayers.get(randomIndex);
        };

        public func getAvailablePlayers(teamId : ?TeamId, position : ?FieldPosition) : Buffer.Buffer<PlayerId> {
            var playersIter : Iter.Iter<(PlayerId, MutablePlayerState)> = state.players.entries()
            // Only good condition players
            |> Iter.filter(_, func(p : (PlayerId, MutablePlayerState)) : Bool = p.1.condition == #ok)
            // Only players not on the field
            |> Iter.filter(_, func(p : (PlayerId, MutablePlayerState)) : Bool = state.positions.get(p.1.position) == null);
            switch (teamId) {
                case (null) {};
                case (?t) {
                    // Only players on the specified team
                    playersIter := Iter.filter(playersIter, func(p : (PlayerId, MutablePlayerState)) : Bool = p.1.teamId == t);
                };
            };
            switch (position) {
                case (null) {};
                case (?po) {
                    // Only players at a certain position
                    playersIter := Iter.filter(playersIter, func(p : (PlayerId, MutablePlayerState)) : Bool = p.1.position == po);
                };
            };
            playersIter
            |> Iter.map(_, func(p : (PlayerId, MutablePlayerState)) : PlayerId = p.0)
            |> Buffer.fromIter(_);
        };

        public func getPlayer(playerId : PlayerId) : MutablePlayerState {
            let ?player = state.players.get(playerId) else Debug.trap("Player not found: " # Nat32.toText(playerId));
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
                    let fieldPosition = playerOut.position; // TODO not always true

                    var availablePlayers = getAvailablePlayers(?playerOut.teamId, ?fieldPosition);
                    if (availablePlayers.size() < 1) {
                        addEvent({
                            description = playerOut.name # " cannot be subbed out because there is no substitute available";
                            effect = #none;
                        });
                    } else {
                        // Get random from available players
                        let randomIndex = randomNat(0, availablePlayers.size());
                        let subPlayerId = availablePlayers.get(randomIndex);
                        // Swap the players in the batting order
                        state.positions.put(fieldPosition, subPlayerId);
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
                case (#movePlayerToBase({ playerId; base })) {
                    // TODO what if other player is already at that position?

                    // Remove player from previous base
                    for ((base, playerIdOnBase) in state.bases.entries()) {
                        if (playerIdOnBase == playerId) {
                            let _ = state.bases.remove(base);
                        };
                    };

                    switch (base) {
                        case (null) {};
                        case (?base) {
                            let playerIdOnBase = state.bases.replace(base, playerId);
                            switch (playerIdOnBase) {
                                case (null) {
                                    // No one on destination base
                                };
                                case (?playerIdOnBase) {
                                    // TODO
                                    Debug.trap("Player " # Nat32.toText(playerIdOnBase) # " already on base " # Player.toTextBase(base));
                                };
                            };
                        };
                    };

                };
                case (#addStrike({ playerId })) {
                    state.strikes += 1;
                    if (state.strikes >= 3) {
                        addEvent({
                            description = "Strikeout";
                            effect = #addOut({
                                playerId = playerId;
                            });
                        });
                    };
                };
                case (#addOut({ playerId })) {
                    state.outs += 1;
                    addEvent({
                        description = "Out"; // TODO
                        effect = #movePlayerToBase({
                            playerId = playerId;
                            base = null;
                        });
                    });
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
                    let (newOffenseTeamId, newDefenseTeamId) = switch (state.offenseTeamId) {
                        case (#team1)(#team2, #team1);
                        case (#team2)(#team1, #team2);
                    };
                    state.offenseTeamId := newOffenseTeamId;
                };
                case (#none) {
                    // Skip
                };
            };
        };

        private func getOffenseTeam() : MutableTeamState {
            switch (state.offenseTeamId) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
        };

        private func getDefenseTeam() : MutableTeamState {
            switch (state.offenseTeamId) {
                case (#team1) state.team2;
                case (#team2) state.team1;
            };
        };

        private func getTeam(teamId : TeamId) : MutableTeamState {
            switch (teamId) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
        };

    };
};
