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
import Blob "mo:base/Blob";
import RandomX "mo:random/RandomX";
import PseudoRandomX "mo:random/PseudoRandomX";
import RandomUtil "../RandomUtil";
import League "../League";

actor class StadiumActor(leagueId : Principal, initLiveStreamCanisterId : Principal) : async Stadium.StadiumActor = this {

    type Match = Stadium.Match;
    type MatchWithTimer = Stadium.MatchWithTimer;
    type MatchWithId = Stadium.MatchWithId;
    type MatchTeamInfo = Stadium.MatchTeamInfo;
    type Player = Player.Player;
    type PlayerWithId = Player.PlayerWithId;
    type PlayerState = Stadium.PlayerState;
    type FieldPosition = Player.FieldPosition;
    type MatchOptions = Stadium.MatchOptions;

    stable var matches : Trie.Trie<Nat32, MatchWithTimer> = Trie.empty();

    stable var nextMatchId : Nat32 = 1;
    stable var liveStreamCanisterId : Principal = initLiveStreamCanisterId;

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

    public shared ({ caller }) func startMatch(matchId : Nat32) : async Stadium.StartMatchResult {
        // TODO: only can call itself after the designated time
        let ?match = getMatchOrNull(matchId) else return #matchNotFound;
        let result = await startMatchInternal(matchId, match);
        switch (result) {
            case (#matchAlreadyStarted) return #matchAlreadyStarted;
            case (#matchNotFound) return #matchNotFound;
            case (#completed(s)) {
                let newMatch : MatchWithTimer = {
                    match with
                    state = #completed(s);
                };
                addOrUpdateMatch(matchId, newMatch);
                #completed(s);
            };
            case (#ok(s)) {
                let newMatch : MatchWithTimer = {
                    match with
                    state = #inProgress(s);
                };
                addOrUpdateMatch(matchId, newMatch);
                #ok(s);
            };
        };
    };

    public shared ({ caller }) func scheduleMatch(request : Stadium.ScheduleMatchRequest) : async Stadium.ScheduleMatchResult {
        assertLeague(caller);
        if (not isTimeAvailable(request.time)) {
            return #timeNotAvailable;
        };
        if (request.team1Id == request.team2Id) {
            return #duplicateTeams;
        };
        let leagueActor = actor (Principal.toText(leagueId)) : League.LeagueActor;
        let teams = try {
            await leagueActor.getTeams();
        } catch (err) {
            return #teamFetchError(Error.message(err));
        };
        let team1OrNull = Array.find(teams, func(t : League.TeamInfo) : Bool { t.id == request.team1Id }) else return #teamNotFound(#team1);
        let team2OrNull = Array.find(teams, func(t : League.TeamInfo) : Bool { t.id == request.team2Id }) else return #teamNotFound(#team1);
        let (team1, team2) = switch ((team1OrNull, team2OrNull)) {
            case (null, null) return #teamNotFound(#bothTeams);
            case (null, ?_) return #teamNotFound(#team1);
            case (?_, null) return #teamNotFound(#team2);
            case (?t1, ?t2)(t1, t2);
        };
        let correctedTeamIds = Util.sortTeamIds((request.team1Id, request.team2Id));
        let timeDiff : Time.Time = request.time - Time.now();
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
        let match : Stadium.MatchWithTimer = {
            id = nextMatchId;
            time = request.time;
            team1 = {
                id = correctedTeamIds.0;
                name = team1.name;
                options = null;
                score = null;
                predictionVotes = 0;
            };
            team2 = {
                id = correctedTeamIds.1;
                name = team2.name;
                options = null;
                score = null;
                predictionVotes = 0;
            };
            offerings = offerings;
            specialRules = specialRules;
            timerId = ?timerId;
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
                #ok(nextMatchKey.key);
            };
        };
    };

    private func startMatchInternal(matchId : Nat32, match : Match) : async Stadium.StartMatchResult {
        switch (match.state) {
            case (#completed(s)) return #completed(s);
            case (#inProgress(_)) return #matchAlreadyStarted;
            case (#notStarted) {};
        };
        let team1InitOrNull = await createTeamInit(matchId, match.team1);
        let team2InitOrNull = await createTeamInit(matchId, match.team2);
        let (team1Init, team2Init) : (MatchSimulator.TeamInitData, MatchSimulator.TeamInitData) = switch (team1InitOrNull, team2InitOrNull) {
            case (null, null) return #completed(#allAbsent);
            case (null, ?_) return #completed(#absentTeam(#team1));
            case (?_, null) return #completed(#absentTeam(#team2));
            case (?t1, ?t2)(t1, t2);
        };
        let seedBlob = await Random.blob();
        let { prng; seed } = RandomUtil.buildPrng(seedBlob);
        let team1IsOffense = prng.nextCoin();
        let initState = MatchSimulator.initState(match.specialRules, team1Init, team2Init, team1IsOffense, prng, seed);
        #ok(initState);
    };

    private func createTeamInit(matchId : Nat32, team : Stadium.MatchTeamInfo) : async ?MatchSimulator.TeamInitData {
        let teamPlayers = await PlayerLedgerActor.getTeamPlayers(?team.id);
        let teamActor = actor (Principal.toText(team.id)) : Team.TeamActor;
        let stadiumId = Principal.fromActor(this);
        let options : MatchOptions = try {
            // Get match options from the team itself
            let result = await teamActor.getMatchOptions(stadiumId, matchId);
            switch (result) {
                case (#noVotes) return null;
                case (#ok(o)) o;
                case (#notAuthorized) Debug.trap("Stadium is not authorized to get match options from team: " # Principal.toText(team.id));
            };
        } catch (err : Error.Error) {
            Debug.print("Failed to get team '" # Principal.toText(team.id) # "': " # Error.message(err));
            return null;
        };
        var specialRuleVotes = Trie.empty<Nat32, Nat>();
        for ((id, vote) in Iter.fromArray(options.specialRuleVotes)) {
            let key = {
                hash = id;
                key = id;
            };
            let (newVotes, _) = Trie.put(specialRuleVotes, key, Nat32.equal, vote);
            specialRuleVotes := newVotes;
        };
        ?{
            id = team.id;
            name = team.name;
            players = teamPlayers;
            offeringId = options.offeringId;
            specialRuleVotes = specialRuleVotes;
        };
    };

    public shared ({ caller }) func tickMatch(matchId : Nat32) : async Stadium.TickMatchResult {
        let ?match = getMatchOrNull(matchId) else return #matchNotFound;
        let state = switch (match.state) {
            case (#completed(completedState)) return #matchOver(completedState);
            case (#inProgress(s)) s;
            case (#notStarted) return #notStarted;
        };
        let prng = PseudoRandomX.LinearCongruentialGenerator(state.currentSeed);
        let newState = MatchSimulator.tick(state, prng);
        switch (newState) {
            case (#completed(completedState)) {
                switch (match.timerId) {
                    case (null) {};
                    // Cancel timer if set
                    case (?timerId) Timer.cancelTimer(timerId);
                };
            };
            case (_) {};
        };
        addOrUpdateMatch(
            matchId,
            {
                match with
                timerId = null;
                state = newState;
            },
        );
        #ok(state);
    };

    private func getMatchOrNull(matchId : Nat32) : ?MatchWithTimer {
        let matchKey = {
            hash = matchId;
            key = matchId;
        };
        Trie.get(matches, matchKey, Nat32.equal);
    };

    private func addOrUpdateMatch(matchId : Nat32, match : MatchWithTimer) {
        let matchKey = {
            hash = matchId;
            key = matchId;
        };
        let (newMatches, _) = Trie.replace(matches, matchKey, Nat32.equal, ?match);
        matches := newMatches;
    };

    private func getRandomOfferings(count : Nat) : [Stadium.OfferingWithId] {
        // TODO
        [
            {
                id = 1;
                deities = ["War"];
                effects = [
                    "+ batting power",
                    "- speed",
                    "Every 5 pitches is a guarenteed fast ball",
                ];
            },
            {
                id = 2;
                deities = ["Mischief"];
                effects = [
                    "+ batting accuracy",
                    "- piety",
                    "Batting has a higher chance of causing injury",
                ];
            },
            {
                id = 3;
                deities = ["Pestilence", "Indulgence"];
                effects = ["+ piety", "- defense", "Players dont rotate between rounds"];
            },
            {
                id = 4;
                deities = ["Pestilence", "Mischief"];
                effects = [
                    "+ throwing power",
                    "- throwing accuracy",
                    "Catching never fails",
                ];
            },
        ];
    };

    private func getRandomSpecialRules(count : Nat) : [Stadium.SpecialRuleWithId] {
        // TODO
        [
            {
                id = 1;
                name = "The skill twist";
                description = "All players' batting power and throwing power are swapped";
            },
            {
                id = 2;
                name = "Fasting";
                description = "All followers of Indulgence are benched for the match";
            },
            {
                id = 3;
                name = "Light Ball";
                description = "Balls are lighter so they are thrown faster and but go less far";
            },
            {
                id = 4;
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

        let teamInfo = if (match.team1.id == teamId) {
            match.team1;
        } else if (match.team2.id == teamId) {
            match.team2;
        } else {
            return #teamNotInMatch;
        };
        let newTeam : MatchTeamInfo = {
            teamInfo with
            options = ?options;
        };
        let newTeams = if (match.team1.id == teamId) {
            (newTeam, match.team2);
        } else {
            (match.team1, newTeam);
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
