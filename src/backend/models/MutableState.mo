import Offering "Offering";
import Player "Player";
import Team "Team";
import MatchAura "MatchAura";
import TrieMap "mo:base/TrieMap";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import StadiumTypes "../stadium/Types";
import FieldPosition "FieldPosition";
import Skill "Skill";

module {

    public type MutableTeamState = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        var score : Int;
        offering : Offering.Offering;
        positions : StadiumTypes.TeamPositions;
    };

    public type MutableBaseState = {
        var atBat : Player.PlayerId;
        var firstBase : ?Player.PlayerId;
        var secondBase : ?Player.PlayerId;
        var thirdBase : ?Player.PlayerId;
    };

    public type MutableMatchState = {
        var offenseTeamId : Team.TeamId;
        var team1 : MutableTeamState;
        var team2 : MutableTeamState;
        aura : MatchAura.MatchAura;
        var players : TrieMap.TrieMap<Player.PlayerId, MutablePlayerState>;
        var log : Buffer.Buffer<StadiumTypes.LogEntry>;
        var bases : MutableBaseState;
        var round : Nat;
        var outs : Nat;
        var strikes : Nat;
        getTeamPlayers : (teamId : Team.TeamId) -> Iter.Iter<(Player.PlayerId, MutablePlayerState)>;
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
        var position : FieldPosition.FieldPosition;
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

    public func toMutableState(state : StadiumTypes.InProgressMatch) : MutableMatchState {
        let players = state.players.vals()
        |> Iter.map<StadiumTypes.PlayerStateWithId, (Nat32, MutablePlayerState)>(
            _,
            func(player : StadiumTypes.PlayerStateWithId) : (Nat32, MutablePlayerState) {
                let state = {
                    name = player.name;
                    var teamId = player.teamId;
                    var condition = player.condition;
                    var skills = toMutableSkills(player.skills);
                    var position = player.position;
                };
                (player.id, state);
            },
        )
        |> TrieMap.fromEntries<Nat32, MutablePlayerState>(_, Nat32.equal, func(h : Nat32) : Nat32 = h);

        let bases = {
            var atBat = state.bases.atBat;
            var firstBase = state.bases.firstBase;
            var secondBase = state.bases.secondBase;
            var thirdBase = state.bases.thirdBase;
        };
        let log = Buffer.fromArray<StadiumTypes.LogEntry>(state.log);
        {
            var offenseTeamId = state.offenseTeamId;
            var team1 = toMutableTeam(state.team1);
            var team2 = toMutableTeam(state.team2);
            var players = players;
            aura = state.aura;
            var bases = bases;
            var log = log;
            var round = state.round;
            var outs = state.outs;
            var strikes = state.strikes;
            getTeamPlayers = func(teamId : Team.TeamId) : Iter.Iter<(Player.PlayerId, MutablePlayerState)> {
                players.entries()
                |> Iter.filter(
                    _,
                    func((_, player) : (Nat32, MutablePlayerState)) : Bool {
                        player.teamId == teamId;
                    },
                );
            };
        };
    };

    public func toMutableTeam(team : StadiumTypes.TeamState) : MutableTeamState {
        {
            id = team.id;
            name = team.name;
            logoUrl = team.logoUrl;
            var score = team.score;
            offering = team.offering;
            positions = team.positions;
        };
    };
};
