import Offering "Offering";
import Player "Player";
import Team "Team";
import MatchAura "MatchAura";
import TrieMap "mo:base/TrieMap";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Debug "mo:base/Debug";
import StadiumTypes "../stadium/Types";
import FieldPosition "FieldPosition";
import Skill "Skill";
import Base "Base";
import Season "Season";

module this {

    public type MutableTeamPositions = {
        var pitcher : Player.PlayerId;
        var firstBase : Player.PlayerId;
        var secondBase : Player.PlayerId;
        var thirdBase : Player.PlayerId;
        var shortStop : Player.PlayerId;
        var leftField : Player.PlayerId;
        var centerField : Player.PlayerId;
        var rightField : Player.PlayerId;
    };

    public type MutableTeamState = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        var score : Int;
        offering : Offering.Offering;
        positions : MutableTeamPositions;
    };

    public type MutableBaseState = {
        var atBat : Player.PlayerId;
        var firstBase : ?Player.PlayerId;
        var secondBase : ?Player.PlayerId;
        var thirdBase : ?Player.PlayerId;
    };

    public type MutableTurnLog = {
        events : Buffer.Buffer<Season.Event>;
    };

    public type MutableRoundLog = {
        turns : Buffer.Buffer<MutableTurnLog>;
    };

    public type MutableMatchLog = {
        rounds : Buffer.Buffer<MutableRoundLog>;
    };

    public class MutableMatchState(immutableState : StadiumTypes.InProgressMatch) = {

        private func toMutableTeam(team : StadiumTypes.TeamState) : MutableTeamState {
            {
                id = team.id;
                name = team.name;
                logoUrl = team.logoUrl;
                var score = team.score;
                offering = team.offering;
                positions = toMutableTeamPositions(team.positions);
            };
        };

        private func toMutableTeamPositions(positions : Season.TeamPositions) : MutableTeamPositions {
            {
                var pitcher = positions.pitcher;
                var firstBase = positions.firstBase;
                var secondBase = positions.secondBase;
                var thirdBase = positions.thirdBase;
                var shortStop = positions.shortStop;
                var leftField = positions.leftField;
                var centerField = positions.centerField;
                var rightField = positions.rightField;
            };
        };

        private func toMutableTurnLog(turn : Season.TurnLog) : MutableTurnLog {
            {
                events = turn.events
                |> Iter.fromArray(_)
                |> Buffer.fromIter<Season.Event>(_);
            };
        };

        private func toMutableRoundLog(round : Season.RoundLog) : MutableRoundLog {
            {
                turns = round.turns
                |> Iter.fromArray(_)
                |> Iter.map(_, toMutableTurnLog)
                |> Buffer.fromIter<MutableTurnLog>(_);
            };
        };

        private func toMutableLog(log : Season.MatchLog) : MutableMatchLog {
            {
                rounds = log.rounds
                |> Iter.fromArray(_)
                |> Iter.map(_, toMutableRoundLog)
                |> Buffer.fromIter<MutableRoundLog>(_);
            };
        };

        public var offenseTeamId = immutableState.offenseTeamId;
        public var team1 = toMutableTeam(immutableState.team1);
        public var team2 = toMutableTeam(immutableState.team2);
        public let aura = immutableState.aura;
        public var bases = {
            var atBat = immutableState.bases.atBat;
            var firstBase = immutableState.bases.firstBase;
            var secondBase = immutableState.bases.secondBase;
            var thirdBase = immutableState.bases.thirdBase;
        };
        public var log = toMutableLog(immutableState.log);
        public var outs = immutableState.outs;
        public var strikes = immutableState.strikes;
        public var players = immutableState.players.vals()
        |> Iter.map<StadiumTypes.PlayerStateWithId, (Nat32, MutablePlayerStateWithId)>(
            _,
            func(player : StadiumTypes.PlayerStateWithId) : (Nat32, MutablePlayerStateWithId) {
                let state = {
                    id = player.id;
                    name = player.name;
                    var teamId = player.teamId;
                    var condition = player.condition;
                    var skills = toMutableSkills(player.skills);
                };
                (player.id, state);
            },
        )
        |> TrieMap.fromEntries<Nat32, MutablePlayerStateWithId>(_, Nat32.equal, func(h : Nat32) : Nat32 = h);

        public func getTeamPlayers(teamId : Team.TeamId) : Iter.Iter<(Player.PlayerId, MutablePlayerState)> {
            players.entries()
            |> Iter.filter(
                _,
                func((_, player) : (Nat32, MutablePlayerState)) : Bool {
                    player.teamId == teamId;
                },
            );
        };
        public func getPlayerState(playerId : Player.PlayerId) : MutablePlayerState {
            let ?player = players.get(playerId) else Debug.trap("Player not found for 'getPlayerState': " # Nat32.toText(playerId));
            player;
        };
        public func getDefensePositionOfPlayer(playerId : Player.PlayerId) : ?FieldPosition.FieldPosition {
            let defensiveTeam = getDefenseTeamState();
            if (defensiveTeam.positions.firstBase == playerId) {
                return ? #firstBase;
            };
            if (defensiveTeam.positions.secondBase == playerId) {
                return ? #secondBase;
            };
            if (defensiveTeam.positions.thirdBase == playerId) {
                return ? #thirdBase;
            };
            if (defensiveTeam.positions.shortStop == playerId) {
                return ? #shortStop;
            };
            if (defensiveTeam.positions.pitcher == playerId) {
                return ? #pitcher;
            };
            if (defensiveTeam.positions.leftField == playerId) {
                return ? #leftField;
            };
            if (defensiveTeam.positions.centerField == playerId) {
                return ? #centerField;
            };
            if (defensiveTeam.positions.rightField == playerId) {
                return ? #rightField;
            };
            null;
        };
        public func getOffensivePositionOfPlayer(playerId : Player.PlayerId) : ?Base.Base {
            if (bases.firstBase == ?playerId) {
                return ? #firstBase;
            };
            if (bases.secondBase == ?playerId) {
                return ? #secondBase;
            };
            if (bases.thirdBase == ?playerId) {
                return ? #thirdBase;
            };
            if (bases.atBat == playerId) {
                return ? #homeBase;
            };
            null;
        };

        public func getPlayerAtBase(base : Base.Base) : ?MutablePlayerState {
            let playerId = switch (base) {
                case (#firstBase) bases.firstBase;
                case (#secondBase) bases.secondBase;
                case (#thirdBase) bases.thirdBase;
                case (#homeBase) ?bases.atBat;
            };
            switch (playerId) {
                case (null) null;
                case (?pId) ?getPlayerState(pId);
            };
        };
        public func getOffenseTeamState() : MutableTeamState {
            switch (offenseTeamId) {
                case (#team1) team1;
                case (#team2) team2;
            };
        };
        public func getDefenseTeamState() : MutableTeamState {
            switch (offenseTeamId) {
                case (#team1) team2;
                case (#team2) team1;
            };
        };
        public func getDefenseTeamId() : Team.TeamId {
            switch (offenseTeamId) {
                case (#team1) #team2;
                case (#team2) #team1;
            };
        };
        public func getTeamState(teamId : Team.TeamId) : MutableTeamState {
            switch (teamId) {
                case (#team1) team1;
                case (#team2) team2;
            };
        };

        public func getPlayerAtDefensivePosition(position : FieldPosition.FieldPosition) : Player.PlayerId {
            let defensiveTeam = getDefenseTeamState();
            switch (position) {
                case (#firstBase) defensiveTeam.positions.firstBase;
                case (#secondBase) defensiveTeam.positions.secondBase;
                case (#thirdBase) defensiveTeam.positions.thirdBase;
                case (#shortStop) defensiveTeam.positions.shortStop;
                case (#pitcher) defensiveTeam.positions.pitcher;
                case (#leftField) defensiveTeam.positions.leftField;
                case (#centerField) defensiveTeam.positions.centerField;
                case (#rightField) defensiveTeam.positions.rightField;
            };
        };

        public func addEvent(event : Season.Event) {
            if (log.rounds.size() == 0) {
                addNewRound();
            };
            let currentRound = log.rounds.get(log.rounds.size() - 1);
            if (currentRound.turns.size() == 0) {
                currentRound.turns.add({
                    events = Buffer.Buffer<Season.Event>(0);
                });
            };
            let currentTurn = currentRound.turns.get(currentRound.turns.size() - 1);
            currentTurn.events.add(event);

        };

        public func endTurn() {
            let currentRound = log.rounds.get(log.rounds.size() - 1);
            currentRound.turns.add({
                events = Buffer.Buffer<Season.Event>(0);
            });
        };

        public func endRound() {
            addNewRound();
        };

        private func addNewRound() {
            let turns = Buffer.Buffer<MutableTurnLog>(0);
            turns.add({
                events = Buffer.Buffer<Season.Event>(0);
            });
            log.rounds.add({
                turns = Buffer.Buffer<MutableTurnLog>(0);
            });
        };
    };

    public type MutablePlayerSkills = {
        var battingPower : Int;
        var battingAccuracy : Int;
        var throwingAccuracy : Int;
        var throwingPower : Int;
        var catching : Int;
        var defense : Int;
        var piety : Int;
        var speed : Int;
    };

    public type MutablePlayerState = {
        name : Text;
        var teamId : Team.TeamId;
        var condition : Player.PlayerCondition;
        var skills : MutablePlayerSkills;
    };

    public type MutablePlayerStateWithId = MutablePlayerState and {
        id : Player.PlayerId;
    };

    public func toMutableSkills(skills : Player.Skills) : MutablePlayerSkills {
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

    public func getPlayerSkill(skills : MutablePlayerSkills, skill : Skill.Skill) : Int {
        switch (skill) {
            case (#battingPower) skills.battingPower;
            case (#battingAccuracy) skills.battingAccuracy;
            case (#throwingPower) skills.throwingPower;
            case (#throwingAccuracy) skills.throwingAccuracy;
            case (#catching) skills.catching;
            case (#defense) skills.defense;
            case (#piety) skills.piety;
            case (#speed) skills.speed;
        };
    };

    public func modifyPlayerSkill(skills : MutablePlayerSkills, skill : Skill.Skill, value : Int) {
        switch (skill) {
            case (#battingPower) skills.battingPower += value;
            case (#battingAccuracy) skills.battingAccuracy += value;
            case (#throwingPower) skills.throwingPower += value;
            case (#throwingAccuracy) skills.throwingAccuracy += value;
            case (#catching) skills.catching += value;
            case (#defense) skills.defense += value;
            case (#piety) skills.piety += value;
            case (#speed) skills.speed += value;
        };
    };
};
