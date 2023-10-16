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
import Timer "mo:base/Timer";
import MatchSimulator "MatchSimulator";
import Random "mo:base/Random";
import Error "mo:base/Error";

actor class StadiumActor(leagueId : Principal) : async Stadium.StadiumActor = this {
    type Match = Stadium.Match;
    type MatchWithId = Stadium.MatchWithId;
    type MatchTeamInfo = Stadium.MatchTeamInfo;
    type Player = Player.Player;
    type PlayerWithId = Player.PlayerWithId;
    type PlayerState = Stadium.PlayerState;
    type FieldPosition = Player.FieldPosition;
    type MatchOptions = Stadium.MatchOptions;

    public type StartMatchResult = {
        #ok;
        #matchNotFound;
        #matchAlreadyStarted;
        #completed : Stadium.CompletedMatchState;
    };

    stable var matches : Trie.Trie<Nat32, Match> = Trie.empty();

    stable var nextMatchId : Nat32 = 1;

    public query func getMatch(id : Nat32) : async ?MatchWithId {

        switch (getMatchOrNull(id)) {
            case (null) return null;
            case (?m) {
                ?{ m with id = id; stadiumId = Principal.fromActor(this) };
            };
        };
    };

    public query func getMatches() : async [MatchWithId] {
        let compare = func(a : MatchWithId, b : MatchWithId) : Order.Order = Int.compare(a.time, b.time);
        let map = func(v : (Nat32, Match)) : MatchWithId = {
            v.1 with
            id = v.0;
            stadiumId = Principal.fromActor(this);
        };
        matches |> Trie.iter _ |> Iter.map(_, map) |> Iter.sort(_, compare) |> Iter.toArray(_);
    };

    public shared ({ caller }) func startMatch(matchId : Nat32) : async StartMatchResult {
        // TODO: only can call itself after the designated time
        let ?match = getMatchOrNull(matchId) else return #matchNotFound;
        switch (match.state) {
            case (#completed(s)) return #completed(s);
            case (#inProgress(_)) return #matchAlreadyStarted;
            case (#notStarted) {};
        };
        let team1InitOrNull = await createTeamInit(matchId, match.teams.0);
        let team2InitOrNull = await createTeamInit(matchId, match.teams.1);
        let (team1Init, team2Init) : (MatchSimulator.TeamInitData, MatchSimulator.TeamInitData) = switch (team1InitOrNull, team2InitOrNull) {
            case (null, null) return #completed(#allAbsent);
            case (null, ?_) return #completed(#absentTeam(#team1));
            case (?_, null) return #completed(#absentTeam(#team2));
            case (?t1, ?t2)(t1, t2);
        };
        let random = Random.Finite(await Random.blob());
        let ?team1IsOffense = random.coin() else Prelude.unreachable();
        let initState = MatchSimulator.initState(match.specialRules, team1Init, team2Init, team1IsOffense, random);
        switch (initState) {
            case (null) return #completed(#allAbsent); // TODO
            case (?s) {
                let newMatch : Match = {
                    match with
                    state = s;
                };
                addOrUpdateMatch(matchId, newMatch);
                ignore tickMatch(matchId);
                #ok;
            };
        };
    };

    private func createTeamInit(matchId : Nat32, team : Stadium.MatchTeamInfo) : async ?MatchSimulator.TeamInitData {
        let teamPlayers = await PlayerLedgerActor.getTeamPlayers(?team.id);
        let teamActor = actor (Principal.toText(team.id)) : Team.TeamActor;
        let options : ?MatchOptions = try {
            // Get match options from the team itself
            await teamActor.getMatchOptions(matchId);
        } catch (err : Error.Error) {
            Debug.print("Failed to get team '" # Principal.toText(team.id) # "': " # Error.message(err));
            null;
        };
        switch (options) {
            case (null) null;
            case (?o) {
                ?{
                    id = team.id;
                    players = teamPlayers;
                    offeringId = o.offeringId;
                    specialRuleVotes = o.specialRuleVotes;
                };
            };
        };
    };

    public shared ({ caller }) func tickMatch(matchId : Nat32) : async Stadium.TickMatchResult {
        let ?match = getMatchOrNull(matchId) else return #matchNotFound;
        let state = switch (match.state) {
            case (#completed(completedState)) return #matchOver(completedState);
            case (#inProgress(s)) s;
            case (#notStarted) return #notStarted;
        };
        let random = Random.Finite(await Random.blob());
        let newState = MatchSimulator.tick(state, random);
        addOrUpdateMatch(
            matchId,
            {
                match with
                state = newState;
            },
        );
        #ok(state);
    };

    private func getMatchOrNull(matchId : Nat32) : ?Match {
        let matchKey = {
            hash = matchId;
            key = matchId;
        };
        Trie.get(matches, matchKey, Nat32.equal);
    };

    private func addOrUpdateMatch(matchId : Nat32, match : Match) {
        let matchKey = {
            hash = matchId;
            key = matchId;
        };
        let (newMatches, _) = Trie.replace(matches, matchKey, Nat32.equal, ?match);
        matches := newMatches;
    };

    public shared ({ caller }) func scheduleMatch(teamIds : (Principal, Principal), time : Time.Time) : async Stadium.ScheduleMatchResult {
        assertLeague(caller);
        if (not isTimeAvailable(time)) {
            return #timeNotAvailable;
        };
        if (teamIds.0 == teamIds.1) {
            return #duplicateTeams;
        };
        let correctedTeamIds = Util.sortTeamIds(teamIds);
        let teamsInfo : (MatchTeamInfo, MatchTeamInfo) = (
            {
                id = correctedTeamIds.0;
                options = null;
                score = null;
                predictionVotes = 0;
            },
            {
                id = correctedTeamIds.1;
                options = null;
                score = null;
                predictionVotes = 0;
            },
        );
        let timeDiff : Time.Time = time - Time.now();
        let natTimeDiff = if (timeDiff < 0) {
            0;
        } else {
            Int.abs(timeDiff);
        };
        let timerDuration = #nanoseconds(natTimeDiff);
        let callbackFunc = func() : async () {
            let _ = await startMatch(nextMatchId);
        };
        let timerId = Timer.setTimer(timerDuration, callbackFunc);
        let offerings = getRandomOfferings(4);
        let specialRules = getRandomSpecialRules(4);
        let match : Match = {
            id = nextMatchId;
            time = time;
            teams = teamsInfo;
            offerings = offerings;
            specialRules = specialRules;
            winner = null;
            timerId = timerId;
            state = #notStarted;
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

    private func getRandomOfferings(count : Nat) : [Stadium.Offering] {
        // TODO
        [
            {
                deities = ["War"];
                effects = [
                    "+ batting power",
                    "- speed",
                    "Every 5 pitches is a guarenteed fast ball",
                ];
            },
            {
                deities = ["Mischief"];
                effects = [
                    "+ batting accuracy",
                    "- piety",
                    "Batting has a higher chance of causing injury",
                ];
            },
            {
                deities = ["Pestilence", "Indulgence"];
                effects = ["+ piety", "- health", "Players dont rotate between rounds"];
            },
            {
                deities = ["Pestilence", "Mischief"];
                effects = [
                    "+ throwing power",
                    "- throwing accuracy",
                    "Catching never fails",
                ];
            },
        ];
    };

    private func getRandomSpecialRules(count : Nat) : [Stadium.SpecialRule] {
        // TODO
        [
            {
                name = "The skill twist";
                description = "All players' batting power and throwing power are swapped";
            },
            {
                name = "Fasting";
                description = "All followers of Indulgence are benched for the match";
            },
            {
                name = "Light Ball";
                description = "Balls are lighter so they are thrown faster and but go less far";
            },
            {
                name = "Sunny day";
                description = "All followers of Pestilence and Miscief are more iritable";
            },
        ];
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
        match : Match,
        options : Stadium.MatchOptions,
    ) : { #ok : Match; #teamNotInMatch } {

        let teamInfo = if (match.teams.0.id == teamId) {
            match.teams.0;
        } else if (match.teams.1.id == teamId) {
            match.teams.1;
        } else {
            return #teamNotInMatch;
        };
        let newTeam : MatchTeamInfo = {
            teamInfo with
            options = ?options;
        };
        let newTeams = if (match.teams.0.id == teamId) {
            (newTeam, match.teams.1);
        } else {
            (match.teams.0, newTeam);
        };

        #ok({
            match with
            teams = newTeams;
        });
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
