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
import PseudoRandomX "mo:random/PseudoRandomX";
import StadiumUtil "StadiumUtil";
import IterTools "mo:itertools/Iter";

module {
    type PlayerState = Stadium.PlayerState;
    type LogEntry = Stadium.LogEntry;
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
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type SimulationResult = {
        #endMatch : Stadium.CompletedMatchState;
        #inProgress;
    };

    type MutableTeamState = {
        id : Principal;
        name : Text;
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
        var log : Buffer.Buffer<LogEntry>;
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
        var speed : Nat;
    };

    type MutablePlayerState = {
        var name : Text;
        var teamId : TeamId;
        var condition : Player.PlayerCondition;
        var skills : MutablePlayerSkills;
        var position : FieldPosition;
    };

    public type TeamInitData = {
        id : Principal;
        name : Text;
        offeringId : Nat32;
        specialRuleVotes : Trie.Trie<Nat32, Nat>;
        players : [PlayerWithId];
    };

    public func initState(
        specialRules : [Stadium.SpecialRule],
        team1 : TeamInitData,
        team2 : TeamInitData,
        team1StartOffense : Bool,
        rand : Prng,
        seed : Nat32,
    ) : InProgressMatchState {
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
        let randomIndex = rand.nextNat(0, offenseTeam.players.size() - 1);
        let atBatPlayer = offenseTeam.players.get(randomIndex);
        let ?defense = buildStartingDefense(defenseTeam.players, rand) else Debug.trap("Not enough players to start match");

        {
            currentSeed = rand.getCurrentSeed();
            offenseTeamId = if (team1StartOffense) #team1 else #team2;
            team1 = {
                id = team1.id;
                name = team1.name;
                score = 0;
                offeringId = team1.offeringId;
            };
            team2 = {
                id = team2.id;
                name = team2.name;
                score = 0;
                offeringId = team2.offeringId;
            };
            specialRuleId = specialRuleId;
            log = [];
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

    private func buildStartingDefense(players : [PlayerWithId], rand : Prng) : ?Stadium.DefenseFieldState {
        let getRandomPlayer = func(position : FieldPosition) : ?PlayerId {
            let playersWithPosition = Array.filter(players, func(p : PlayerWithId) : Bool = p.position == position);
            if (playersWithPosition.size() < 1) {
                return null;
            };
            let index = rand.nextNat(0, playersWithPosition.size() - 1);
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

    public func tick(state : InProgressMatchState, random : Prng) : MatchState {
        let simulation = MatchSimulation(state, random);
        simulation.tick();
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
            var speed = skills.speed;
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
        let log = Buffer.fromArray<LogEntry>(state.log);
        {
            var offenseTeamId = state.offenseTeamId;
            var team1 = toMutableTeam(state.team1);
            var team2 = toMutableTeam(state.team2);
            var players = players;
            specialRuleId = state.specialRuleId;
            var field = field;
            var log = log;
            var round = state.round;
            var outs = state.outs;
            var strikes = state.strikes;
        };
    };

    private func toMutableTeam(team : TeamState) : MutableTeamState {
        {
            id = team.id;
            name = team.name;
            var score = team.score;
            offeringId = team.offeringId;
        };
    };

    class MatchSimulation(initialState : InProgressMatchState, random : Prng) {

        let state : MutableMatchState = toMutableState(initialState);

        public func tick() : MatchState {
            let divineInterventionRoll = random.nextNat(0, 999);
            if (divineInterventionRoll >= 991) {
                // TODO divine intervention
            };
            let result = pitch();
            buildState(result);
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

        public func buildState(result : SimulationResult) : MatchState {
            switch (result) {
                case (#inProgress) {};
                case (#endMatch(s)) return #completed(s);
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
                                speed = player.1.skills.speed;
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
                    name = team.name;
                    score = team.score;
                    offeringId = team.offeringId;
                };
            };
            let log : [LogEntry] = Buffer.toArray(state.log);
            #inProgress({
                currentSeed = random.getCurrentSeed();
                offenseTeamId = state.offenseTeamId;
                team1 = buildTeam(state.team1);
                team2 = buildTeam(state.team2);
                specialRuleId = state.specialRuleId;
                log = log;
                players = players;
                field = field;
                round = state.round;
                outs = state.outs;
                strikes = state.strikes;
            });
        };

        private func getRandomAvailablePlayer(teamId : ?TeamId, position : ?FieldPosition, notOnField : Bool) : ?PlayerId {
            // get random player
            let availablePlayers = getAvailablePlayers(teamId, position, notOnField);
            if (availablePlayers.size() < 1) {
                return null;
            };
            let randomIndex = random.nextNat(0, availablePlayers.size() - 1);
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

        private func getPlayerAtBase(base : Base) : ?MutablePlayerState {
            let playerId = switch (base) {
                case (#firstBase) state.field.offense.firstBase;
                case (#secondBase) state.field.offense.secondBase;
                case (#thirdBase) state.field.offense.thirdBase;
                case (#homeBase) ?state.field.offense.atBat;
            };
            switch (playerId) {
                case (null) null;
                case (?pId) ?getPlayer(pId);
            };
        };

        private func pitch() : SimulationResult {
            let pitcher = getPlayer(state.field.defense.pitcher);
            let pitchRoll = random.nextNat(0, 10) + pitcher.skills.throwingAccuracy + pitcher.skills.throwingPower;

            state.log.add({
                description = "Pitch";
                isImportant = false;
            });
            let atBatPlayer = getPlayer(state.field.offense.atBat);
            let batterRoll = random.nextInt(0, 10) + atBatPlayer.skills.battingAccuracy + atBatPlayer.skills.battingPower;
            let batterNetScore = batterRoll - pitchRoll;
            if (batterNetScore <= 0) {
                strike();
            } else {
                hit({ hitRoll = Int.abs(batterNetScore) });
            };
        };

        private func foul() : SimulationResult {
            state.log.add({
                description = "Foul ball";
                isImportant = true;
            });
            #inProgress;
        };

        private func hit({ hitRoll : Nat }) : SimulationResult {
            state.log.add({
                description = "Its a hit! ";
                isImportant = true;
            });
            let precisionRoll = random.nextInt(-2, 2) + hitRoll;
            if (precisionRoll < 0) {
                return foul();
            };
            let player = getPlayer(state.field.offense.atBat);
            if (precisionRoll > 10) {
                state.log.add({
                    description = "Homerun!";
                    isImportant = true;
                });
                // hit it out of the park
                return batterRun({ fromBase = #homeBase; ballLocation = null });
            };
            let location = switch (random.nextInt(0, 7)) {
                case (0) #firstBase;
                case (1) #secondBase;
                case (2) #thirdBase;
                case (3) #shortStop;
                case (4) #pitcher;
                case (5) #leftField;
                case (6) #centerField;
                case (7) #rightField;
                case (_) Prelude.unreachable();
            };
            let catchingPlayerId = getPlayerAtPosition(location);
            let catchingPlayer = getPlayer(catchingPlayerId);
            let catchRoll = random.nextInt(-10, 10) + catchingPlayer.skills.catching;
            if (catchRoll <= 0) {
                batterRun({
                    fromBase = #homeBase;
                    ballLocation = ?location;
                });
            } else {
                let locationText = switch (location) {
                    case (#firstBase) "at first base";
                    case (#secondBase) "at second base";
                    case (#thirdBase) "at third base";
                    case (#shortStop) "at short stop";
                    case (#pitcher) "at the pitching mound";
                    case (#leftField) "in left field";
                    case (#centerField) "in center field";
                    case (#rightField) "in right field";
                };
                state.log.add({
                    description = catchingPlayer.name # " caught the ball " # locationText # "!";
                    isImportant = true;
                });
                // Ball caught, batter is out
                out(state.field.offense.atBat);
            };

        };

        private func batterRun({
            ballLocation : ?FieldPosition;
        }) : SimulationResult {
            let battingPlayer = getPlayer(state.field.offense.atBat);

            let runRoll : Nat = random.nextNat(0, 10) + battingPlayer.skills.speed;
            let runPlayerToBase = func(playerId : ?PlayerId, base : Base) : SimulationResult {
                switch (playerId) {
                    case (null) {
                        #inProgress;
                    };
                    case (?pId) {
                        let player = getPlayer(pId);
                        playerMovedBases({ playerId = pId; base = base });
                    };
                };
            };
            switch (ballLocation) {
                case (null) {
                    // Home run
                    switch (runPlayerToBase(state.field.offense.thirdBase, #homeBase)) {
                        case (#endMatch(m)) return #endMatch(m);
                        case (#inProgress) {};
                    };
                    switch (runPlayerToBase(state.field.offense.secondBase, #homeBase)) {
                        case (#endMatch(m)) return #endMatch(m);
                        case (#inProgress) {};
                    };
                    switch (runPlayerToBase(state.field.offense.firstBase, #homeBase)) {
                        case (#endMatch(m)) return #endMatch(m);
                        case (#inProgress) {};
                    };
                    runPlayerToBase(?state.field.offense.atBat, #homeBase);
                };
                case (?l) {
                    // TODO the other bases should be able to get out, but they just run free right now
                    switch (runPlayerToBase(state.field.offense.thirdBase, #homeBase)) {
                        case (#endMatch(m)) return #endMatch(m);
                        case (#inProgress) {};
                    };
                    switch (runPlayerToBase(state.field.offense.secondBase, #thirdBase)) {
                        case (#endMatch(m)) return #endMatch(m);
                        case (#inProgress) {};
                    };
                    switch (runPlayerToBase(state.field.offense.firstBase, #secondBase)) {
                        case (#endMatch(m)) return #endMatch(m);
                        case (#inProgress) {};
                    };

                    let catchingPlayerId = getPlayerAtPosition(l);
                    let catchingPlayer = getPlayer(catchingPlayerId);
                    let canPickUpInTime = random.nextInt(0, 10) + catchingPlayer.skills.speed;
                    if (canPickUpInTime <= 0) {
                        return #inProgress;
                    };
                    // TODO against dodge/speed skill of runner
                    let throwRoll = random.nextInt(-10, 10) + catchingPlayer.skills.throwingAccuracy;
                    if (throwRoll <= 0) {
                        state.log.add({
                            description = "SAFE!";
                            isImportant = true;
                        });
                        playerMovedBases({
                            playerId = state.field.offense.atBat;
                            base = #firstBase;
                        });
                    } else {
                        state.log.add({
                            description = "Player " # catchingPlayer.name # " hit " # battingPlayer.name # "!";
                            isImportant = true;
                        });
                        switch (out(state.field.offense.atBat)) {
                            case (#endMatch(m)) return #endMatch(m);
                            case (#inProgress) {};
                        };
                        let defenseRoll = random.nextInt(-10, 10) + battingPlayer.skills.defense;
                        let damageRoll = throwRoll - defenseRoll;
                        if (damageRoll > 5) {
                            let newInjury = switch (damageRoll) {
                                case (6) #twistedAnkle;
                                case (7) #brokenLeg;
                                case (8) #brokenArm;
                                case (_) #concussion;
                            };
                            injurePlayer({
                                playerId = state.field.offense.atBat;
                                injury = newInjury;
                            });
                        } else {
                            #inProgress;
                        };

                    };

                };
            };

        };

        private func strike() : SimulationResult {
            state.strikes += 1;
            state.log.add({
                description = "Strike " # Nat.toText(state.strikes);
                isImportant = false;
            });
            if (state.strikes >= 3) {
                out(state.field.offense.atBat);
            } else {
                #inProgress;
            };
        };

        private func out(playerId : Nat32) : SimulationResult {
            state.strikes := 0;
            state.outs += 1;
            state.log.add({
                description = "Player " # getPlayer(playerId).name # " is out";
                isImportant = true;
            });
            if (state.outs >= 3) {
                return endRound();
            };
            removePlayerFromField(playerId);
        };

        private func playerMovedBases({ base : Base; playerId : PlayerId }) : SimulationResult {
            switch (base) {
                case (#firstBase) state.field.offense.firstBase := ?playerId;
                case (#secondBase) state.field.offense.secondBase := ?playerId;
                case (#thirdBase) state.field.offense.thirdBase := ?playerId;
                // TODO should this be legal?
                case (#homeBase) {
                    score({ teamId = state.offenseTeamId; amount = 1 });
                };
            };
            removePlayerFromField(playerId);
        };

        private func endRound() : SimulationResult {
            state.strikes := 0;
            state.outs := 0;
            state.round += 1;
            state.log.add({
                description = "Round is over";
                isImportant = true;
            });
            if (state.round > 9) {
                // End match if no more rounds
                return endMatch(#noMoreRounds);
            };
            let (newOffenseTeamId, newDefenseTeamId) = switch (state.offenseTeamId) {
                case (#team1)(#team2, #team1);
                case (#team2)(#team1, #team2);
            };
            state.offenseTeamId := newOffenseTeamId;
            let newDefense = buildNewDefense(newDefenseTeamId);
            let newOffense = buildNewOffense(newOffenseTeamId);
            switch ((newDefense, newOffense)) {
                case (null, null) return endMatch(#outOfPlayers(#bothTeams));
                case (?d, null) return endMatch(#outOfPlayers(newOffenseTeamId));
                case (null, ?o) return endMatch(#outOfPlayers(newDefenseTeamId));
                case (?d, ?o) {
                    state.field.defense := d;
                    state.field.offense := o;
                };
            };
            let newState = [
                ("At Bat", state.field.offense.atBat),
                ("1st Base", state.field.defense.firstBase),
                ("2nd Base", state.field.defense.secondBase),
                ("3rd Base", state.field.defense.thirdBase),
                ("Short Stop", state.field.defense.shortStop),
                ("Pitcher", state.field.defense.pitcher),
                ("Left Field", state.field.defense.leftField),
                ("Center Field", state.field.defense.centerField),
                ("Right Field", state.field.defense.rightField),
            ];
            let newPositionText = IterTools.fold(
                newState.vals(),
                "Team " # getTeam(newDefenseTeamId).name # " is now on the field.\nNew positions -",
                func(m : Text, p : (Text, PlayerId)) : Text = m # "\n" # p.0 # ": " # getPlayer(p.1).name,
            );
            state.log.add({
                description = newPositionText;
                isImportant = false;
            });
            #inProgress;
        };

        private func injurePlayer({ playerId : Nat32; injury : Player.Injury }) : SimulationResult {
            let player = getPlayer(playerId);
            player.condition := #injured(injury);
            let injuryText = switch (injury) {
                case (#twistedAnkle) "Twisted ankle";
                case (#brokenLeg) "Broken leg";
                case (#brokenArm) "Broken arm";
                case (#concussion) "Concussion";
            };
            state.log.add({
                description = "Player " # player.name # " is injured: " # injuryText;
                isImportant = true;
            });
            if (getDefensePositionOfPlayer(playerId) != null) {
                // Swap if on field, base swap handled by batterRun
                substitutePlayer({ playerId = playerId });
            } else {
                #inProgress;
            };
        };

        private func substitutePlayer({ playerId : Nat32 }) : SimulationResult {
            let playerOut = getPlayer(playerId);
            let team = switch (playerOut.teamId) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
            let ?fieldPosition = getDefensePositionOfPlayer(playerId) else trapWithEvents("Player not on field, cannot sub out: " # Nat32.toText(playerId));

            var availablePlayers = getAvailablePlayers(?playerOut.teamId, ?fieldPosition, true);
            if (availablePlayers.size() < 1) {
                return endMatch(#outOfPlayers(playerOut.teamId));
            };
            // Get random from available players
            let randomIndex = random.nextNat(0, availablePlayers.size() - 1);
            let subPlayerId = availablePlayers.get(randomIndex);
            let subPlayer = getPlayer(subPlayerId);

            state.log.add({
                description = "Player " # playerOut.name # " is being substituted by " # subPlayer.name;
                isImportant = true;
            });
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
            #inProgress;
        };

        private func score({ teamId : TeamId; amount : Int }) {
            let team = switch (teamId) {
                case (#team1) state.team1;
                case (#team2) state.team2;
            };
            team.score += amount;
            state.log.add({
                description = "Team " #team.name # " scored " #Int.toText(amount) # " points!";
                isImportant = true;
            });
        };

        private func endMatch(reason : Stadium.MatchEndReason) : SimulationResult {
            let (winner, message) = switch (reason) {
                case (#noMoreRounds) {
                    let winner = if (state.team1.score > state.team2.score) {
                        #team1;
                    } else if (state.team1.score == state.team2.score) {
                        #tie;
                    } else {
                        #team2;
                    };
                    (winner, "Match ended due to no more rounds");
                };
                case (#outOfPlayers(teamId)) {
                    switch (teamId) {
                        case (#bothTeams) {
                            (#tie, "Match ended due to both teams running out of players");
                        };
                        case (#team1) {
                            (#team1, "Match ended due to team '" # getTeam(#team1).name # "' running out of players");
                        };
                        case (#team2) {
                            (#team2, "Match ended due to team '" # getTeam(#team2).name # "' running out of players");
                        };
                    };
                };

            };
            state.log.add({
                description = message;
                isImportant = true;
            });
            switch (winner) {
                case (#tie) state.log.add({
                    description = "The match ended in a tie!";
                    isImportant = true;
                });
                case (#team1) state.log.add({
                    description = "Team " # getTeam(#team1).name # " wins!";
                    isImportant = true;
                });
                case (#team2) state.log.add({
                    description = "Team " # getTeam(#team2).name # " wins!";
                    isImportant = true;
                });
            };

            let buildTeam = func(team : MutableTeamState) : Stadium.CompletedTeamState {
                {
                    id = team.id;
                    score = team.score;
                };
            };

            let log : [LogEntry] = Buffer.toArray(state.log);
            let completedState = {
                team1 = buildTeam(state.team1);
                team2 = buildTeam(state.team2);
                log = log;
                winner = winner;
            };
            #endMatch(#played(completedState));
        };

        private func removePlayerFromField(playerId : PlayerId) : SimulationResult {
            let ?position = getOffensePositionOfPlayer(playerId) else trapWithEvents("Player not on field, cannot remove: " # Nat32.toText(playerId));

            switch (position) {
                case (#firstBase) state.field.offense.firstBase := null;
                case (#secondBase) state.field.offense.secondBase := null;
                case (#thirdBase) state.field.offense.thirdBase := null;
                case (#homeBase) {
                    let ?nextBatterId = getRandomAvailablePlayer(?state.offenseTeamId, null, true) else {
                        return endMatch(#outOfPlayers(state.offenseTeamId));
                    };
                    state.field.offense.atBat := nextBatterId;
                    state.log.add({
                        description = "Player " # getPlayer(nextBatterId).name # " is up to bat";
                        isImportant = true;
                    });
                };
            };
            #inProgress;
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
            let messageWithEvents = state.log.vals()
            |> IterTools.fold<LogEntry, Text>(
                _,
                message,
                func(m : Text, e : LogEntry) : Text = m # "\n" # e.description,
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
