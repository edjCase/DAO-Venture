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
import Text "mo:base/Text";
import RandomX "mo:random/RandomX";
import StadiumUtil "StadiumUtil";
import IterTools "mo:itertools/Iter";

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
        id : Principal;
        var score : Int;
        offeringId : Nat32;
    };

    type MutableDefenseFieldState = {
        var firstBase : PlayerId;
        var secondBase : PlayerId;
        var thirdBase : PlayerId;
        var shortStop : PlayerId;
        var pitcher : PlayerId;
        var leftField : PlayerId;
        var centerField : PlayerId;
        var rightField : PlayerId;
    };

    type MutableOffenseFieldState = {
        var atBat : PlayerId;
        var firstBase : ?PlayerId;
        var secondBase : ?PlayerId;
        var thirdBase : ?PlayerId;
    };

    type MutableFieldState = {
        var offense : MutableOffenseFieldState;
        var defense : MutableDefenseFieldState;
    };

    type MutableMatchState = {
        var offenseTeamId : TeamId;
        var team1 : MutableTeamState;
        var team2 : MutableTeamState;
        specialRuleId : ?Nat32;
        var players : TrieMap.TrieMap<PlayerId, MutablePlayerState>;
        var events : Buffer.Buffer<Event>;
        var batter : ?PlayerId;
        var field : MutableFieldState;
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
        rand : RandomX.FiniteX,
    ) : ?InProgressMatchState {
        var players = Buffer.Buffer<Stadium.PlayerStateWithId>(team1.players.size() + team2.players.size());
        let addPlayer = func(player : PlayerWithId, teamId : TeamId) {
            let playerState : Stadium.PlayerStateWithId = {
                id = player.id;
                name = player.name;
                teamId = teamId;
                condition = player.condition;
                skills = player.skills;
                position = player.position;
            };
            players.add(playerState);
        };
        for (player in team1.players.vals()) {
            addPlayer(player, #team1);
        };
        for (player in team2.players.vals()) {
            addPlayer(player, #team2);
        };
        let specialRuleId = calculateSpecialRule(specialRules, team1.specialRuleVotes, team2.specialRuleVotes);

        let (offenseTeam, defenseTeam) = if (team1StartOffense) {
            (team1, team2);
        } else {
            (team2, team1);
        };
        let ?randomIndex = rand.nat(0, offenseTeam.players.size() - 1) else return null;
        let atBatPlayer = offenseTeam.players.get(randomIndex);
        let ?defense = buildStartingDefense(defenseTeam.players, rand) else return null;

        ?{
            offenseTeamId = if (team1StartOffense) #team1 else #team2;
            team1 = {
                id = team1.id;
                score = 0;
                offeringId = team1.offeringId;
            };
            team2 = {
                id = team2.id;
                score = 0;
                offeringId = team2.offeringId;
            };
            specialRuleId = specialRuleId;
            events = [];
            players = Buffer.toArray(players);
            batter = null;
            field = {
                offense = {
                    atBat = atBatPlayer.id;
                    firstBase = null;
                    secondBase = null;
                    thirdBase = null;
                };
                defense = defense;
            };
            round = 0;
            outs = 0;
            strikes = 0;
        };
    };

    private func buildStartingDefense(players : [PlayerWithId], rand : RandomX.FiniteX) : ?Stadium.DefenseFieldState {
        let getRandomPlayer = func(position : FieldPosition) : ?PlayerId {
            let playersWithPosition = Array.filter(players, func(p : PlayerWithId) : Bool = p.position == position);
            if (playersWithPosition.size() < 1) {
                return null;
            };
            let ?index = rand.nat(0, playersWithPosition.size() - 1) else return null;
            ?playersWithPosition[index].id;
        };

        do ? {
            {
                firstBase = getRandomPlayer(#firstBase)!;
                secondBase = getRandomPlayer(#secondBase)!;
                thirdBase = getRandomPlayer(#thirdBase)!;
                shortStop = getRandomPlayer(#shortStop)!;
                pitcher = getRandomPlayer(#pitcher)!;
                leftField = getRandomPlayer(#leftField)!;
                centerField = getRandomPlayer(#centerField)!;
                rightField = getRandomPlayer(#rightField)!;
            };
        };
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

    public func tick(state : InProgressMatchState, random : RandomX.FiniteX) : MatchState {
        let simulation = MatchSimulation(state, random);
        simulation.tick();
    };

    // TODO handle limited entropy from random by refetching entropy from the chain
    class MatchSimulation(initialState : InProgressMatchState, random : RandomX.FiniteX) {

        public func tick() : MatchState {
            pitch();
            buildState();
        };

        private func toMutableSkills(skills : PlayerSkills) : MutablePlayerSkills {
            {
                var battingPower = skills.battingPower;
                var battingAccuracy = skills.battingAccuracy;
                var throwingPower = skills.throwingPower;
                var throwingAccuracy = skills.throwingAccuracy;
                var catching = skills.catching;
                var defense = skills.defense;
                var piety = skills.piety;
            };
        };

        private func toMutableState(state : InProgressMatchState) : MutableMatchState {
            let players = state.players.vals()
            |> Iter.map<Stadium.PlayerStateWithId, (Nat32, MutablePlayerState)>(
                _,
                func(player : Stadium.PlayerStateWithId) : (Nat32, MutablePlayerState) {
                    let state = {
                        var name = player.name;
                        var teamId = player.teamId;
                        var condition = player.condition;
                        var skills = toMutableSkills(player.skills);
                        var position = player.position;
                    };
                    (player.id, state);
                },
            )
            |> TrieMap.fromEntries<Nat32, MutablePlayerState>(_, Nat32.equal, func(h : Nat32) : Nat32 = h);

            let field = {
                var offense = {
                    var atBat = state.field.offense.atBat;
                    var firstBase = state.field.offense.firstBase;
                    var secondBase = state.field.offense.secondBase;
                    var thirdBase = state.field.offense.thirdBase;
                };
                var defense = {
                    var firstBase = state.field.defense.firstBase;
                    var secondBase = state.field.defense.secondBase;
                    var thirdBase = state.field.defense.thirdBase;
                    var shortStop = state.field.defense.shortStop;
                    var pitcher = state.field.defense.pitcher;
                    var leftField = state.field.defense.leftField;
                    var centerField = state.field.defense.centerField;
                    var rightField = state.field.defense.rightField;
                };
            };
            {
                var offenseTeamId = state.offenseTeamId;
                var team1 = toMutableTeam(initialState.team1);
                var team2 = toMutableTeam(initialState.team2);
                var players = players;
                specialRuleId = state.specialRuleId;
                var field = field;
                var batter = state.batter;
                var events = Buffer.fromArray(initialState.events);
                var round = initialState.round;
                var outs = initialState.outs;
                var strikes = initialState.strikes;
            };
        };

        private func pitch() {
            let atBatPlayer = getPlayer(state.field.offense.atBat);
            let pitcher = getPlayer(state.field.defense.pitcher);
            let pitchRoll = randomInt(0, 10) + pitcher.skills.throwingAccuracy + pitcher.skills.throwingPower;
            let batterRoll = randomInt(0, 10) + atBatPlayer.skills.battingAccuracy + atBatPlayer.skills.battingPower;
            let batterNetScore = batterRoll - pitchRoll;
            if (batterNetScore <= 0) {
                addEvent({
                    description = "Strike " # Nat.toText(state.strikes + 1);
                    effect = #addStrike({
                        playerId = state.field.offense.atBat;
                    });
                });
            } else {
                hit(Int.abs(batterNetScore));
            };
        };

        private func hit(batterNetScore : Nat) {
            let precisionRoll = randomInt(-2, 2) + batterNetScore;
            if (precisionRoll < 0) {
                addEvent({
                    description = "Foul";
                    effect = #none;
                });
            } else {
                let player = getPlayer(state.field.offense.atBat);
                let hitLocation = if (precisionRoll > 10) {
                    addEvent({
                        description = player.name # " hits a homerun!";
                        effect = #none;
                    });
                    #outOfPark;
                } else {
                    let (location, name) = switch (randomInt(0, 7)) {
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
                    addEvent({
                        description = player.name # " hits the ball to " # name;
                        effect = #none;
                    });
                    location;
                };
                run(hitLocation);
            };
        };

        private func run(hitLocation : HitLocation) {
            switch (hitLocation) {
                case (#outOfPark) {
                    addEvent({
                        description = "Home run!";
                        effect = #none;
                    });
                };
                case (#firstBase) tryCatch(#firstBase);
                case (#secondBase) tryCatch(#secondBase);
                case (#thirdBase) tryCatch(#thirdBase);
                case (#shortStop) tryCatch(#shortStop);
                case (#pitcher) tryCatch(#pitcher);
                case (#leftField) tryCatch(#leftField);
                case (#centerField) tryCatch(#centerField);
                case (#rightField) tryCatch(#rightField);
            };

        };

        private func getPlayerAtPosition(catchLocation : FieldPosition) : PlayerId {
            switch (catchLocation) {
                case (#firstBase) state.field.defense.firstBase;
                case (#secondBase) state.field.defense.secondBase;
                case (#thirdBase) state.field.defense.thirdBase;
                case (#shortStop) state.field.defense.shortStop;
                case (#pitcher) state.field.defense.pitcher;
                case (#leftField) state.field.defense.leftField;
                case (#centerField) state.field.defense.centerField;
                case (#rightField) state.field.defense.rightField;
            };
        };

        private func tryCatch(catchLocation : FieldPosition) {
            let catchingPlayerId = getPlayerAtPosition(catchLocation);
            let catchingPlayer = getPlayer(catchingPlayerId);
            let catchRoll = randomInt(-10, 10) + catchingPlayer.skills.catching;
            if (catchRoll <= 0) {
                addEvent({
                    description = catchingPlayer.name # " misses the catch";
                    effect = #none;
                });
                let canPickUpInTime = randomInt(0, 10) + catchingPlayer.skills.catching;
                if (canPickUpInTime > 0) {
                    addEvent({
                        description = catchingPlayer.name # " picks up the ball";
                        effect = #none;
                    });
                    // TODO the other bases should be able to get out, but they just run free right now
                    runPlayerToBase(state.field.offense.thirdBase, #homeBase, "home");
                    runPlayerToBase(state.field.offense.secondBase, #thirdBase, "third base");
                    runPlayerToBase(state.field.offense.firstBase, #secondBase, "second base");

                    // TODO against dodge/speed skill of runner
                    let throwRoll = randomInt(-10, 10) + catchingPlayer.skills.throwingAccuracy;
                    if (throwRoll <= 0) {
                        addEvent({
                            description = catchingPlayer.name # " misses the throw";
                            effect = #none;
                        });
                        addEvent({
                            description = "Runner is safe";
                            effect = #movePlayerToBase({
                                playerId = state.field.offense.atBat;
                                base = ? #firstBase;
                            });
                        });
                    } else {
                        addEvent({
                            description = catchingPlayer.name # " throws the ball and hits the player";
                            effect = #addOut({
                                playerId = state.field.offense.atBat;
                            });
                        });

                        let runningPlayer = getPlayer(state.field.offense.atBat);
                        let defenseRoll = randomInt(-10, 10) + runningPlayer.skills.defense;
                        let damageRoll = throwRoll - defenseRoll;
                        if (damageRoll > 5) {
                            let (newInjury, newInjuryText) = switch (damageRoll) {
                                case (6)(#twistedAnkle, "Twisted ankle");
                                case (7)(#brokenLeg, "Broken leg");
                                case (8)(#brokenArm, "Broken arm");
                                case (_)(#concussion, "Concussion");
                            };
                            addEvent({
                                description = runningPlayer.name # " was injured by the throw. Injury: " # newInjuryText;
                                effect = #setPlayerCondition({
                                    playerId = state.field.offense.atBat;
                                    condition = #injured(newInjury);
                                });
                            });
                        };
                    };
                } else {
                    addEvent({
                        description = catchingPlayer.name # " cannot pick up the ball in time";
                        effect = #none;
                    });
                };
            } else {
                addEvent({
                    description = catchingPlayer.name # " catches the ball";
                    effect = #addOut({
                        playerId = state.field.offense.atBat;
                    });
                });
            };
        };

        private func runPlayerToBase(playerId : ?PlayerId, base : Base, baseText : Text) {

            switch (playerId) {
                case (null) {};
                case (?pId) {
                    let player = getPlayer(pId);
                    if (base == #homeBase) {
                        addEvent({
                            description = "Player " # player.name # " ran home";
                            effect = #movePlayerToBase({
                                playerId = pId;
                                base = null;
                            });
                        });
                        addEvent({
                            description = "Player " # player.name # " scored a run";
                            effect = #increaseScore({
                                teamId = player.teamId;
                                amount = 1;
                            });
                        });
                    } else {
                        addEvent({
                            description = "Player " # player.name # " ran to " # baseText;
                            effect = #movePlayerToBase({
                                playerId = pId;
                                base = ?base;
                            });
                        });
                    };
                };
            };
        };

        private func toMutableTeam(team : TeamState) : MutableTeamState {
            {
                id = team.id;
                var score = team.score;
                offeringId = team.offeringId;
            };
        };

        let state : MutableMatchState = toMutableState(initialState);

        public func buildState() : MatchState {
            switch (isEndState()) {
                case (null) {};
                case (?s) return #completed(s);
            };

            let players = Iter.toArray(
                Iter.map(
                    state.players.entries(),
                    func(player : (Nat32, MutablePlayerState)) : Stadium.PlayerStateWithId {
                        {
                            id = player.0;
                            name = player.1.name;
                            teamId = player.1.teamId;
                            condition = player.1.condition;
                            position = player.1.position;
                            skills = {
                                battingPower = player.1.skills.battingPower;
                                battingAccuracy = player.1.skills.battingAccuracy;
                                throwingPower = player.1.skills.throwingPower;
                                throwingAccuracy = player.1.skills.throwingAccuracy;
                                catching = player.1.skills.catching;
                                defense = player.1.skills.defense;
                                piety = player.1.skills.piety;
                            };
                        };
                    },
                )
            );

            let field = {
                offense = {
                    atBat = state.field.offense.atBat;
                    firstBase = state.field.offense.firstBase;
                    secondBase = state.field.offense.secondBase;
                    thirdBase = state.field.offense.thirdBase;
                };
                defense = {
                    firstBase = state.field.defense.firstBase;
                    secondBase = state.field.defense.secondBase;
                    thirdBase = state.field.defense.thirdBase;
                    shortStop = state.field.defense.shortStop;
                    pitcher = state.field.defense.pitcher;
                    leftField = state.field.defense.leftField;
                    centerField = state.field.defense.centerField;
                    rightField = state.field.defense.rightField;
                };
            };

            let buildTeam = func(team : MutableTeamState) : TeamState {
                {
                    id = team.id;
                    score = team.score;
                    offeringId = team.offeringId;
                };
            };
            #inProgress({
                offenseTeamId = state.offenseTeamId;
                team1 = buildTeam(state.team1);
                team2 = buildTeam(state.team2);
                specialRuleId = state.specialRuleId;
                events = Buffer.toArray(state.events);
                players = players;
                batter = state.batter;
                field = field;
                round = state.round;
                outs = state.outs;
                strikes = state.strikes;
            });
        };

        private func isEndState() : ?Stadium.CompletedMatchState {
            let buildTeam = func(team : MutableTeamState) : Stadium.CompletedTeamState {
                {
                    id = team.id;
                    score = team.score;
                };
            };

            if (state.round >= 9) {
                let winner = if (state.team1.score > state.team2.score) {
                    #team1;
                } else if (state.team1.score == state.team2.score) {
                    #team1; // TODO do random
                } else {
                    #team2;
                };
                let playerChanges = Trie.empty(); // TODO
                return ? #played(
                    {
                        team1 = buildTeam(state.team1);
                        team2 = buildTeam(state.team2);
                        events = Buffer.toArray(state.events);
                        winner = winner;
                        playerChanges = playerChanges;
                    }
                );
            };
            let minPlayerCount = 8; // TODO
            let team1PlayerCount = Iter.size(IterTools.mapFilter(state.players.vals(), func(p : MutablePlayerState) : ?MutablePlayerState = if (p.teamId == #team1) { ?p } else { null }));
            let team2PlayerCount = Iter.size(IterTools.mapFilter(state.players.vals(), func(p : MutablePlayerState) : ?MutablePlayerState = if (p.teamId == #team2) { ?p } else { null }));
            if (team1PlayerCount < minPlayerCount or team2PlayerCount < minPlayerCount) {
                let winner = if (team1PlayerCount >= minPlayerCount) {
                    #team1;
                } else if (team2PlayerCount >= minPlayerCount) {
                    #team2;
                } else {
                    #team2; // TODO random
                };
                return ? #played({
                    team1 = buildTeam(state.team1);
                    team2 = buildTeam(state.team2);
                    events = Buffer.toArray(state.events);
                    winner = winner;
                    playerChanges = Trie.empty();
                });
            };
            null;
        };

        private func randomInt(min : Int, max : Int) : Int {
            let ?v = random.int(min, max) else trapWithEvents("Random ran out of entropy"); // TODO
            v;
        };

        private func randomNat(min : Nat, max : Nat) : Nat {
            let ?v = random.nat(min, max) else trapWithEvents("Random ran out of entropy"); // TODO
            v;
        };

        private func getRandomAvailablePlayer(teamId : ?TeamId, position : ?FieldPosition, notOnField : Bool) : ?PlayerId {
            // get random player
            let availablePlayers = getAvailablePlayers(teamId, position, notOnField);
            if (availablePlayers.size() < 1) {
                return null;
            };
            let randomIndex = randomNat(0, availablePlayers.size() - 1);
            ?availablePlayers.get(randomIndex);

        };

        private func getAvailablePlayers(teamId : ?TeamId, position : ?FieldPosition, notOnField : Bool) : Buffer.Buffer<PlayerId> {

            var playersIter : Iter.Iter<(PlayerId, MutablePlayerState)> = state.players.entries()
            // Only good condition players
            |> Iter.filter(_, func(p : (PlayerId, MutablePlayerState)) : Bool = p.1.condition == #ok);
            if (notOnField) {
                // Only players not on the field
                playersIter := Iter.filter(
                    playersIter,
                    func(p : (PlayerId, MutablePlayerState)) : Bool {
                        getDefensePositionOfPlayer(p.0) == null and getOffensePositionOfPlayer(p.0) == null;
                    },
                );
            };

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
                    // Only players assigned to a certain position
                    playersIter := Iter.filter(playersIter, func(p : (PlayerId, MutablePlayerState)) : Bool = p.1.position == po);
                };
            };
            playersIter
            |> Iter.map(_, func(p : (PlayerId, MutablePlayerState)) : PlayerId = p.0)
            |> Buffer.fromIter(_);
        };

        private func getPlayer(playerId : PlayerId) : MutablePlayerState {
            let ?player = state.players.get(playerId) else trapWithEvents("Player not found: " # Nat32.toText(playerId));
            player;
        };

        private func getDefensePositionOfPlayer(playerId : PlayerId) : ?FieldPosition {
            if (state.field.defense.firstBase == playerId) {
                return ? #firstBase;
            };
            if (state.field.defense.secondBase == playerId) {
                return ? #secondBase;
            };
            if (state.field.defense.thirdBase == playerId) {
                return ? #thirdBase;
            };
            if (state.field.defense.shortStop == playerId) {
                return ? #shortStop;
            };
            if (state.field.defense.pitcher == playerId) {
                return ? #pitcher;
            };
            if (state.field.defense.leftField == playerId) {
                return ? #leftField;
            };
            if (state.field.defense.centerField == playerId) {
                return ? #centerField;
            };
            if (state.field.defense.rightField == playerId) {
                return ? #rightField;
            };
            null;
        };

        private func getOffensePositionOfPlayer(playerId : PlayerId) : ?Base {
            if (state.field.offense.firstBase == ?playerId) {
                return ? #firstBase;
            };
            if (state.field.offense.secondBase == ?playerId) {
                return ? #secondBase;
            };
            if (state.field.offense.thirdBase == ?playerId) {
                return ? #thirdBase;
            };
            if (state.field.offense.atBat == playerId) {
                return ? #homeBase;
            };
            null;
        };

        private func getPlayerIdAtOffsensePosition(base : Base) : ?PlayerId {
            switch (base) {
                case (#firstBase) state.field.offense.firstBase;
                case (#secondBase) state.field.offense.secondBase;
                case (#thirdBase) state.field.offense.thirdBase;
                case (#homeBase) ?state.field.offense.atBat;
            };
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
                    let ?fieldPosition = getDefensePositionOfPlayer(playerOutId) else trapWithEvents("Player not on field, cannot sub out: " # Nat32.toText(playerOutId));

                    var availablePlayers = getAvailablePlayers(?playerOut.teamId, ?fieldPosition, true);
                    if (availablePlayers.size() < 1) {
                        addEvent({
                            description = playerOut.name # " cannot be subbed out because there is no substitute available";
                            effect = #none;
                        });
                    } else {
                        // Get random from available players
                        let randomIndex = randomNat(0, availablePlayers.size() - 1);
                        let subPlayerId = availablePlayers.get(randomIndex);
                        switch (fieldPosition) {
                            case (#firstBase) state.field.defense.firstBase := subPlayerId;
                            case (#secondBase) state.field.defense.secondBase := subPlayerId;
                            case (#thirdBase) state.field.defense.thirdBase := subPlayerId;
                            case (#shortStop) state.field.defense.shortStop := subPlayerId;
                            case (#pitcher) state.field.defense.pitcher := subPlayerId;
                            case (#leftField) state.field.defense.leftField := subPlayerId;
                            case (#centerField) state.field.defense.centerField := subPlayerId;
                            case (#rightField) state.field.defense.rightField := subPlayerId;
                        };
                        let subPlayer = getPlayer(subPlayerId);
                        addEvent({
                            description = playerOut.name # " is being subbed out by " # subPlayer.name;
                            effect = #none;
                        });
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
                    if (substituteOut and getDefensePositionOfPlayer(playerId) != null) {
                        addEvent({
                            description = player.name # " has been substituted out due to condition";
                            effect = #subPlayer({
                                playerOutId = playerId;
                            });
                        });
                    };
                };
                case (#movePlayerToBase({ playerId; base })) {

                    let oldPosition = getOffensePositionOfPlayer(playerId);

                    switch (base) {
                        case (null) {
                            // Remove from field
                        };
                        case (?b) {
                            let playerIdAtNewPosition = switch (getPlayerIdAtOffsensePosition(b)) {
                                case (null) {
                                    // No one at new position, skip
                                };
                                case (?pId) {
                                    // TODO other players running shouldnt be a push
                                    let playerAlreadyOnBase = getPlayer(pId);
                                    let runningPlayer = getPlayer(playerId);
                                    trapWithEvents("Player " # playerAlreadyOnBase.name # " is in the way of " # runningPlayer.name);
                                };
                            };
                            switch (b) {
                                case (#firstBase) state.field.offense.firstBase := ?playerId;
                                case (#secondBase) state.field.offense.secondBase := ?playerId;
                                case (#thirdBase) state.field.offense.thirdBase := ?playerId;
                                // TODO should this be legal?
                                case (#homeBase) state.field.offense.atBat := playerId;
                            };
                        };
                    };
                    // Remove from old position
                    switch (oldPosition) {
                        case (null) {
                            // Skip, wasn't on field
                        };
                        case (? #firstBase) state.field.offense.firstBase := null;
                        case (? #secondBase) state.field.offense.secondBase := null;
                        case (? #thirdBase) state.field.offense.thirdBase := null;
                        case (? #homeBase) {
                            let ?nextBatterId = getRandomAvailablePlayer(?state.offenseTeamId, null, true) else {
                                addEvent({
                                    description = "No more players available to bat";
                                    effect = #endRound; // TODO end match?
                                });
                                return;
                            };
                            state.field.offense.atBat := nextBatterId;
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
                    state.strikes := 0;
                    state.outs += 1;
                    addEvent({
                        description = "Player " # getPlayer(playerId).name # " is out";
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
                    state.strikes := 0;
                    state.outs := 0;
                    state.round += 1;
                    let (newOffenseTeamId, newDefenseTeamId) = switch (state.offenseTeamId) {
                        case (#team1)(#team2, #team1);
                        case (#team2)(#team1, #team2);
                    };
                    state.offenseTeamId := newOffenseTeamId;
                    let ?newDefense = buildNewDefense(newDefenseTeamId) else trapWithEvents("Not enough players to continue match"); // TODO forfeit?
                    state.field.defense := newDefense;
                    let ?newOffense = buildNewOffense(newOffenseTeamId) else trapWithEvents("Not enough players to continue match"); // TODO forfeit?
                    state.field.offense := newOffense;
                };
                case (#none) {
                    // Skip
                };
            };
        };

        private func buildNewDefense(teamId : TeamId) : ?MutableDefenseFieldState {
            do ? {
                {
                    var pitcher = getRandomAvailablePlayer(?teamId, ? #pitcher, false)!;
                    var firstBase = getRandomAvailablePlayer(?teamId, ? #firstBase, false)!;
                    var secondBase = getRandomAvailablePlayer(?teamId, ? #secondBase, false)!;
                    var thirdBase = getRandomAvailablePlayer(?teamId, ? #thirdBase, false)!;
                    var shortStop = getRandomAvailablePlayer(?teamId, ? #shortStop, false)!;
                    var leftField = getRandomAvailablePlayer(?teamId, ? #leftField, false)!;
                    var centerField = getRandomAvailablePlayer(?teamId, ? #centerField, false)!;
                    var rightField = getRandomAvailablePlayer(?teamId, ? #rightField, false)!;
                };
            };
        };

        private func buildNewOffense(teamId : TeamId) : ?MutableOffenseFieldState {

            do ? {
                {
                    var atBat = getRandomAvailablePlayer(?teamId, null, false)!;
                    var firstBase = null;
                    var secondBase = null;
                    var thirdBase = null;
                };
            };
        };

        private func trapWithEvents(message : Text) : None {
            let messageWithEvents = IterTools.fold<Event, Text>(
                state.events.vals(),
                message,
                func(m : Text, e : Event) : Text = m # "\n" # e.description,
            );
            Debug.trap(messageWithEvents);
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
