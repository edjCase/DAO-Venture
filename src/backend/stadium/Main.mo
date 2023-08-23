import Player "../Player";
import Principal "mo:base/Principal";
import Team "../Team";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import Stadium "../Stadium";
import Nat "mo:base/Nat";
import Util "./StadiumUtil";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import TrieSet "mo:base/TrieSet";
import PlayerLedgerActor "canister:playerLedger";
import Order "mo:base/Order";
import Int "mo:base/Int";

actor class StadiumActor(leagueId : Principal) : async Stadium.StadiumActor {

    public type MatchInfo = Stadium.Match and {
        id : Nat32;
    };

    stable var matches : Trie.Trie<Nat32, Stadium.Match> = Trie.empty();

    stable var nextMatchId : Nat32 = 1;

    public query func getMatches() : async [MatchInfo] {
        let compare = func(a : MatchInfo, b : MatchInfo) : Order.Order = Int.compare(a.time, b.time);
        let map = func(v : (Nat32, Stadium.Match)) : MatchInfo = {
            v.1 with
            id = v.0;
        };
        // matches |> Trie.iter _ |> Iter.map(_, map) |> Iter.sort(_, compare) |> Iter.toArray(_);
        Iter.toArray(
            Iter.sort(
                Iter.map(
                    Trie.iter(matches),
                    map,
                ),
                compare,
            )
        );
    };

    public shared ({ caller }) func registerForMatch(
        matchId : Nat32,
        teamConfig : Stadium.TeamConfiguration,
    ) : async Stadium.RegisterResult {
        let matchKey = {
            hash = matchId;
            key = matchId;
        };
        let ?match = Trie.get(matches, matchKey, Nat32.equal) else return #matchNotFound;
        if (match.time < Time.now()) {
            return #matchAlreadyStarted;
        };
        let teamPlayers = await PlayerLedgerActor.getTeamPlayers(?caller);
        let teamPlayerIds = Array.map<PlayerLedgerActor.PlayerInfoWithId, Nat32>(teamPlayers, func(p) = p.id);
        switch (validateTeamConfig(teamConfig, teamPlayerIds)) {
            case (#ok) {
                let newMatch = switch (buildNewMatch(caller, match, teamConfig)) {
                    case (#ok(match)) match;
                    case (#teamNotInMatch) return #teamNotInMatch;
                };
                let (newMatches, _) = Trie.replace(matches, matchKey, Nat32.equal, ?newMatch);
                matches := newMatches;
                #ok;
            };
            case (#invalidTeamConfig(e)) return #invalidTeamConfig(e);
            case (#matchAlreadyStarted) return #matchAlreadyStarted;
            case (#matchNotFound) return #matchNotFound;
            case (#teamNotInMatch) return #teamNotInMatch;
        };
    };

    public shared ({ caller }) func scheduleMatch(teamIds : [Principal], time : Time.Time) : async Stadium.ScheduleMatchResult {
        assertLeague(caller);
        if (not isTimeAvailable(time)) {
            return #timeNotAvailable;
        };
        // TODO validate teams?
        let teamsInfo = Array.map<Principal, Stadium.MatchTeamInfo>(
            teamIds,
            func(teamId) = {
                id = teamId;
                config = null;
                score = null;
            },
        );
        let match : Stadium.Match = {
            id = nextMatchId;
            time = time;
            teams = teamsInfo;
            winner = null;
        };
        let nextMatchKey = {
            hash = nextMatchId;
            key = nextMatchId;
        };
        switch (Trie.put(matches, nextMatchKey, Nat32.equal, match)) {
            case (_, ?previous) Prelude.unreachable(); // Cant duplicate ids
            case (newMatches, _) {
                nextMatchId += 1;
                matches := newMatches;
                #ok;
            };
        };
    };

    private func isTimeAvailable(time : Time.Time) : Bool {
        for ((matchId, match) in Trie.iter(matches)) {
            // TODO better time window detection
            if (Time.now() >= time or match.time == time) {
                return false;
            };
        };
        true;
    };

    private func buildNewMatch(
        teamId : Principal,
        match : Stadium.Match,
        teamConfig : Stadium.TeamConfiguration,
    ) : { #ok : Stadium.Match; #teamNotInMatch } {

        let teamsBuffer = Buffer.fromArray<Stadium.MatchTeamInfo>(match.teams);
        var teamIndex = 0;
        label l for (team in teamsBuffer.vals()) {
            if (team.id == teamId) {
                break l;
            };
        };
        if (teamIndex >= teamsBuffer.size()) {
            // Couldn't find the team in the match
            return #teamNotInMatch;
        };
        let teamInfo = teamsBuffer.get(teamIndex);

        let newTeam = {
            teamInfo with
            configuration = teamConfig;
        };
        teamsBuffer.put(teamIndex, newTeam);

        #ok({
            match with
            teams = Buffer.toArray(teamsBuffer)
        });
    };

    private func validateTeamConfig(
        teamConfig : Stadium.TeamConfiguration,
        allPlayerIds : [Nat32],
    ) : Stadium.RegisterResult {
        let allPlayerIdsSet = TrieSet.fromArray(allPlayerIds, hashNat32, Nat32.equal);

        let fieldPlayers = [
            teamConfig.pitcher,
            teamConfig.catcher,
            teamConfig.firstBase,
            teamConfig.secondBase,
            teamConfig.thirdBase,
            teamConfig.shortStop,
            teamConfig.leftField,
            teamConfig.centerField,
            teamConfig.rightField,
        ];

        // Validate that all players are on the team
        switch (validatePlayers(Iter.fromArray(fieldPlayers), allPlayerIdsSet)) {
            case (#ok) {};
            case (#invalid(e)) return #invalidTeamConfig(e);
        };
        let fieldPlayersSet = TrieSet.fromArray(fieldPlayers, hashNat32, Nat32.equal);

        // Validate all the field players are in the batting order
        switch (validatePlayers(Iter.fromArray(teamConfig.battingOrder), fieldPlayersSet)) {
            case (#ok) {};
            case (#invalid(e)) return #invalidTeamConfig(e);
        };

        let unusedPlayerSet = Trie.diff(allPlayerIdsSet, fieldPlayersSet, Nat32.equal);

        // Substitute players can not be the same as field players
        switch (validatePlayers(Iter.fromArray(teamConfig.substitutes), unusedPlayerSet)) {
            case (#ok) {};
            case (#invalid(e)) return #invalidTeamConfig(e);
        };

        #ok;
    };

    private func validatePlayers(players : Iter.Iter<Nat32>, validPlayerIds : TrieSet.Set<Nat32>) : {
        #ok;
        #invalid : [Stadium.PlayerValidationError];
    } {
        var playersInUse = TrieSet.empty<Nat32>();
        let errors = Buffer.Buffer<Stadium.PlayerValidationError>(0);
        for (playerId in players) {
            if (not TrieSet.mem(validPlayerIds, playerId, playerId, Nat32.equal)) {
                errors.add(#notOnTeam(playerId));
            };
            if (TrieSet.mem(playersInUse, playerId, playerId, Nat32.equal)) {
                errors.add(#usedInMultiplePositions(playerId));
            };
            playersInUse := TrieSet.put(playersInUse, playerId, playerId, Nat32.equal);
        };
        if (errors.size() > 0) {
            return #invalid(Buffer.toArray(errors));
        };
        #ok;
    };

    private func hashNat32(n : Nat32) : Hash.Hash {
        n;
    };

    private func assertLeague(caller : Principal) {
        if (caller != leagueId) {
            Debug.trap("Only the league can schedule matches");
        };
    };
};
