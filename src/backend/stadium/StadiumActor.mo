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
import IterTools "mo:itertools/Iter";

actor class StadiumActor(leagueId : Principal) : async Stadium.StadiumActor = this {

    type Match = Stadium.Match;
    type MatchGroupWithTimer = Stadium.MatchGroupWithTimer;
    type MatchWithId = Stadium.MatchWithId;
    type MatchTeamInfo = Stadium.MatchTeamInfo;
    type Player = Player.Player;
    type PlayerWithId = Player.PlayerWithId;
    type PlayerState = Stadium.PlayerState;
    type FieldPosition = Player.FieldPosition;
    type MatchOptions = Stadium.MatchOptions;
    type Offering = Stadium.Offering;
    type MatchAura = Stadium.MatchAura;
    type Prng = PseudoRandomX.PseudoRandomGenerator;
    type TeamWithId = Team.TeamWithId;

    stable var matchGroups : Trie.Trie<Nat32, MatchGroupWithTimer> = Trie.empty();

    stable var nextMatchGroupId : Nat32 = 1;

    public query func getMatchGroup(id : Nat32) : async ?Stadium.MatchGroupWithId {
        switch (getMatchGroupOrNull(id)) {
            case (null) return null;
            case (?m) {
                ?{
                    m with id = id;
                    stadiumId = Principal.fromActor(this);
                };
            };
        };
    };

    public query func getMatchGroups() : async [Stadium.MatchGroupWithId] {
        matchGroups
        |> Trie.iter _
        |> Iter.map(
            _,
            func(v : (Nat32, MatchGroupWithTimer)) : Stadium.MatchGroupWithId = {
                v.1 with
                id = v.0;
                stadiumId = Principal.fromActor(this);
            },
        )
        |> Iter.sort(_, func(a : Stadium.MatchGroupWithId, b : Stadium.MatchGroupWithId) : Order.Order = Int.compare(a.time, b.time))
        |> Iter.toArray(_);
    };

    public shared ({ caller }) func startMatchGroup(matchGroupId : Nat32) : async Stadium.StartMatchResult {
        // TODO: only can call itself after the designated time
        let ?match = getMatchOrNull(matchId) else return #matchNotFound;
        let (result, newMatch) = switch (await startMatchInternal(matchId, match)) {
            case (#matchAlreadyStarted) return #matchAlreadyStarted;
            case (#matchNotFound) return #matchNotFound;
            case (#completed(s)) {
                let newMatch : MatchWithTimer = {
                    match with
                    timer = null;
                    state = #completed(s);
                };
                (#completed(s), newMatch);
            };
            case (#ok(s)) {
                let timerId = Timer.recurringTimer(
                    #seconds(5),
                    func() : async () {
                        let _ = await tickMatch(matchId);
                    },
                );
                let newMatch : MatchWithTimer = {
                    match with
                    timerId = ?timerId;
                    state = #inProgress(s);
                };
                (#ok(s), newMatch);
            };
        };
        // Clear timer if set on original match
        switch (match.timerId) {
            case (null)();
            case (?timerId) Timer.cancelTimer(timerId);
        };
        addOrUpdateMatch(matchId, newMatch);
        result;
    };

    type MatchResult = Stadium.ScheduleMatchFailure or {
        #ok : Match;
    };
    public shared ({ caller }) func scheduleMatchGroup(request : Stadium.ScheduleMatchGroupRequest) : async Stadium.ScheduleMatchGroupResult {
        assertLeague(caller);
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromSeed(Blob.hash(seedBlob));
        let divisionActor = actor (Principal.toText(request.divisionId)) : League.LeagueActor;
        let teams = try {
            await divisionActor.getTeams();
        } catch (err) {
            return #teamFetchError(Error.message(err));
        };
        let timeDiff : Time.Time = request.time - Time.now();
        let natTimeDiff = if (timeDiff < 0) {
            1;
        } else {
            Int.abs(timeDiff);
        };
        let timerDuration = #nanoseconds(natTimeDiff);
        let matchGroupId = nextMatchGroupId; // StadiumActor needs to be here to preserve the matchId value for the callback
        let callbackFunc = func() : async () {
            let message = switch (await startMatchGroup(matchGroupId)) {
                case (#matchAlreadyStarted) "Failed to start match: Match already started";
                case (#matchNotFound) "Failed to start match: Match not found";
                case (#completed(_)) "Failed to start match: Match completed";
                case (#ok(_)) "Started match: " # Nat32.toText(matchGroupId);
            };
            Debug.print("Start Match Callback Result - " # message);
        };
        let timerId = Timer.setTimer(timerDuration, callbackFunc);

        let matches = Buffer.Buffer<Match>(request.matches.size());
        let failedMatches = Buffer.Buffer<Stadium.ScheduleMatchFailure>(0);
        for (m in Iter.fromArray(request.matches)) {
            switch (scheduleMatch(m, teams, prng)) {
                case (#ok(m)) matches.add(m);
                case (#teamNotFound(t)) failedMatches.add(#teamNotFound(t));
            };
        };
        if (failedMatches.size() > 0) {
            return #matchErrors(Buffer.toArray(failedMatches));
        };

        let matchGroup : Stadium.MatchGroup = {
            time = request.time;
            matches = Buffer.toArray(matches);
        };
        let nextMatchGroupKey = {
            hash = nextMatchGroupId;
            key = nextMatchGroupId;
        };
        switch (Trie.put(matchGroups, nextMatchGroupKey, Nat32.equal, matchGroup)) {
            case (_, ?previous) Prelude.unreachable(); // Cant duplicate ids
            case (newMatchGroups, _) {
                nextMatchGroupId += 1;
                matchGroups := newMatchGroups;
                #ok(nextMatchGroupKey.key);
            };
        };
    };

    public shared ({ caller }) func tickMatchGroup(matchGroupId : Nat32) : async Stadium.TickMatchGroupResult {
        let ?matchGroup = getMatchGroupOrNull(matchGroupId) else return #matchGroupNotFound;
        let newMatches = matchGroup.matches
        |> Buffer.fromArray<Match>(_)
        |> Buffer.map<Match, Match>(
            _,
            func(m : Match) : Match {
                let newState = tickMatchState(m.state);
                {
                    m with
                    state = newState;
                };
            },
        );
        let allComplete = IterTools.all(
            newMatches.vals(),
            func(m : Match) : Bool = switch (m.state) {
                case (#completed(_)) true;
                case (_) false;
            },
        );
        let timerId = if (allComplete) {
            switch (matchGroup.timerId) {
                case (null) {};
                // Cancel timer if set
                case (?timerId) Timer.cancelTimer(timerId);
            };

            null;
        } else {
            matchGroup.timerId;
        };
        #inProgress({
            matchGroup with
            matches = Buffer.toArray(newMatches);
            timerId = timerId;
        });
    };

    private func scheduleMatch(m : Stadium.ScheduleMatchRequest, teams : [TeamWithId], prng : Prng) : MatchResult {
        let correctedTeamIds = Util.sortTeamIds((m.team1Id, m.team2Id));
        let team1OrNull = Array.find(teams, func(t : TeamWithId) : Bool = t.id == correctedTeamIds.0);
        let team2OrNull = Array.find(teams, func(t : TeamWithId) : Bool = t.id == correctedTeamIds.1);
        let (team1, team2) = switch ((team1OrNull, team2OrNull)) {
            case (null, null) return #teamNotFound(#bothTeams);
            case (null, ?_) return #teamNotFound(#team1);
            case (?_, null) return #teamNotFound(#team2);
            case (?t1, ?t2)(t1, t2);
        };
        let offerings = getRandomOfferings(4);
        let aura = getRandomMatchAura(prng);
        #ok({
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
            aura = aura;
            state = #notStarted;
        });
    };

    private func tickMatchState(state : Stadium.MatchState) : Stadium.MatchState {
        switch (state) {
            case (#notStarted) #notStarted;
            case (#completed(completedState)) #completed(completedState);
            case (#inProgress(s)) {
                let prng = PseudoRandomX.LinearCongruentialGenerator(s.currentSeed);
                MatchSimulator.tick(s, prng);
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
        let initState = MatchSimulator.initState(match.aura, team1Init, team2Init, team1IsOffense, prng, seed);
        #ok(initState);
    };

    private func createTeamInit(matchGroupId : Nat32, team : Stadium.MatchTeamInfo) : async ?MatchSimulator.TeamInitData {
        let teamPlayers = await PlayerLedgerActor.getTeamPlayers(?team.id);
        let teamActor = actor (Principal.toText(team.id)) : Team.TeamActor;
        let stadiumId = Principal.fromActor(this);
        let options : MatchOptions = try {
            // Get match options from the team itself
            let result = await teamActor.getMatchGroupVote(matchGroupId);
            switch (result) {
                case (#noVotes) return null;
                case (#ok(o)) o;
                case (#notAuthorized) Debug.trap("Stadium is not authorized to get match options from team: " # Principal.toText(team.id));
            };
        } catch (err : Error.Error) {
            Debug.print("Failed to get team '" # Principal.toText(team.id) # "': " # Error.message(err));
            return null;
        };
        ?{
            id = team.id;
            name = team.name;
            players = teamPlayers;
            offering = options.offering;
            champion = options.champion;
        };
    };

    private func getMatchGroupOrNull(matchGroupId : Nat32) : ?MatchGroupWithTimer {
        let matchGroupKey = {
            hash = matchGroupId;
            key = matchGroupId;
        };
        Trie.get(matchGroups, matchGroupKey, Nat32.equal);
    };

    private func addOrUpdateMatchGroup(matchGroupId : Nat32, matchGroup : MatchGroupWithTimer) {
        let matchGroupKey = {
            hash = matchGroupId;
            key = matchGroupId;
        };
        let (newMatchGroups, _) = Trie.replace(matchGroups, matchGroupKey, Nat32.equal, ?matchGroup);
        matchGroups := newMatchGroups;
    };

    private func getRandomOfferings(count : Nat) : [Stadium.Offering] {
        // TODO
        [
            #mischief(#shuffleAndBoost),
            #war(#b),
            #indulgence(#c),
            #pestilence(#d),
        ];
    };

    private func getRandomMatchAura(prng : Prng) : Stadium.MatchAura {
        // TODO
        let auras = Buffer.fromArray<Stadium.MatchAura>([
            #lowGravity,
            #explodingBalls,
            #fastBallsHardHits,
            #highBlessingsAndCurses,
        ]);
        prng.shuffleBuffer(auras);
        auras.get(0);
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
