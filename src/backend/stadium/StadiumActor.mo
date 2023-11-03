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
    type MatchGroup = Stadium.MatchGroup;
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
    type StartMatchResult = {
        #inProgress : Stadium.InProgressMatchState;
        #completed : Stadium.CompletedMatchState;
    };

    stable var matchGroups : Trie.Trie<Nat32, MatchGroup> = Trie.empty();

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
            func(v : (Nat32, MatchGroup)) : Stadium.MatchGroupWithId = {
                v.1 with
                id = v.0;
            },
        )
        |> Iter.sort(_, func(a : Stadium.MatchGroupWithId, b : Stadium.MatchGroupWithId) : Order.Order = Int.compare(a.time, b.time))
        |> Iter.toArray(_);
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

        let matches = Buffer.Buffer<Stadium.Match>(request.matches.size());
        let failedMatches = Buffer.Buffer<Stadium.ScheduleMatchFailure>(0);
        for (m in Iter.fromArray(request.matches)) {
            let team1OrNull = Array.find(teams, func(t : TeamWithId) : Bool = t.id == m.team1Id);
            let team2OrNull = Array.find(teams, func(t : TeamWithId) : Bool = t.id == m.team2Id);
            switch ((team1OrNull, team2OrNull)) {
                case (null, null) failedMatches.add(#teamNotFound(#bothTeams));
                case (null, ?_) failedMatches.add(#teamNotFound(#team1));
                case (?_, null) failedMatches.add(#teamNotFound(#team2));
                case (?t1, ?t2) matches.add(buildMatch(m, t1, t2, prng));
            };
        };
        if (failedMatches.size() > 0) {
            return #matchErrors(Buffer.toArray(failedMatches));
        };
        let matchGroup : Stadium.MatchGroup = {
            time = request.time;
            state = #notStarted({
                matches = Buffer.toArray(matches);
                startTimerId = startTimerId;
            });
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
        let matchGroupState : Stadium.InProgressMatchGroupState = switch (matchGroup.state) {
            case (#notStarted(notStartedState)) {
                let seedBlob = await Random.blob();
                let { prng; seed } = RandomUtil.buildPrng(seedBlob);
                Timer.cancelTimer(notStartedState.startTimerId); // Cancel timer before disposing of timer id
                let tickTimerId = Timer.recurringTimer(
                    #seconds(5000),
                    func() : async () {
                        await tickMatchGroupCallback(matchGroupId);
                    },
                );
                let startedMatches = Buffer.Buffer<Stadium.StartedMatchState>(notStartedState.matches.size());
                for (match in Iter.fromArray(notStartedState.matches)) {
                    try {
                        let startedMatch = await startMatchInternal(matchGroupId, match, prng);
                        startedMatches.add(startedMatch);
                    } catch (err) {
                        // TODO handle single match failing or make not async
                        Debug.print("Failed to start match: " # Error.message(err));
                    };
                };
                {
                    notStartedState with
                    matches = Buffer.toArray(startedMatches);
                    tickTimerId = tickTimerId;
                    seed = seed;
                };
            };
            case (#completed(_)) return #completed;
            case (#inProgress(g)) g;
        };
        let newState = switch (tickMatches(matchGroupState.matches)) {
            case (#completed(completedMatches)) {
                // Cancel tick timer before disposing of timer id
                Timer.cancelTimer(matchGroupState.tickTimerId);

                #completed({
                    matchGroupState with
                    matches = completedMatches;
                });
            };
            case (#inProgress(newMatches)) {
                #inProgress({
                    matchGroupState with
                    matches = newMatches;
                });
            };
        };
        let newMatchGroup = {
            matchGroup with
            state = newState;
        };
        addOrUpdateMatchGroup(matchGroupId, newMatchGroup);
        switch (newState) {
            case (#completed(_)) #completed;
            case (#inProgress(_)) #ok;
        };
    };

    private func tickMatchGroupCallback(matchGroupId : Nat32) : async () {
        let message = switch (await tickMatchGroup(matchGroupId)) {
            case (#matchGroupNotFound) "Failed to start match group: Match Group not found";
            case (#completed(_)) "Failed to start match group: Match Group completed";
            case (#inProgress(_)) "Started match group: " # Nat32.toText(matchGroupId);
        };
        Debug.print("Start Match Group Callback Result - " # message);
    };

    private func tickMatches(matches : [Stadium.StartedMatchState]) : {
        #completed : [Stadium.CompletedMatchState];
        #inProgress : [Stadium.StartedMatchState];
    } {

        let completedMatchStates = Buffer.Buffer<Stadium.CompletedMatchState>(0);
        let newMatchStates = Buffer.Buffer<Stadium.StartedMatchState>(0);
        for (matchState in Iter.fromArray(matches)) {

            let newMatchState = tickMatchState(matchState);
            newMatchStates.add(newMatchState);
            switch (newMatchState) {
                case (#completed(completedState)) completedMatchStates.add(completedState);
                case (#inProgress(_)) newMatchStates.add(newMatchState);
            };
        };
        if (completedMatchStates.size() == newMatchStates.size()) {
            // If all matches are complete, then complete the group
            #completed(Buffer.toArray(completedMatchStates));
        } else {
            #inProgress(Buffer.toArray(newMatchStates));
        };
    };

    private func buildMatch(
        m : Stadium.ScheduleMatchRequest,
        team1 : TeamWithId,
        team2 : TeamWithId,
        prng : Prng,
    ) : Stadium.Match {

        let offerings = getRandomOfferings(4);
        let aura = getRandomMatchAura(prng);
        {
            team1 = {
                id = team1.id;
                name = team1.name;
                options = null;
                score = null;
                predictionVotes = 0;
            };
            team2 = {
                id = team2.id;
                name = team2.name;
                options = null;
                score = null;
                predictionVotes = 0;
            };
            offerings = offerings;
            aura = aura;
            state = #notStarted;
        };
    };

    private func tickMatchState(state : Stadium.StartedMatchState) : Stadium.StartedMatchState {
        switch (state) {
            case (#completed(completedState)) #completed(completedState);
            case (#inProgress(s)) {
                let prng = PseudoRandomX.LinearCongruentialGenerator(s.currentSeed);
                MatchSimulator.tick(s, prng);
            };
        };
    };

    private func startMatchInternal(matchGroupId : Nat32, match : Stadium.Match, prng : Prng) : async StartMatchResult {
        let team1InitOrNull = await createTeamInit(matchGroupId, match.team1);
        let team2InitOrNull = await createTeamInit(matchGroupId, match.team2);
        let (team1Init, team2Init) : (MatchSimulator.TeamInitData, MatchSimulator.TeamInitData) = switch (team1InitOrNull, team2InitOrNull) {
            case (null, null) return #completed(#allAbsent);
            case (null, ?_) return #completed(#absentTeam(#team1));
            case (?_, null) return #completed(#absentTeam(#team2));
            case (?t1, ?t2)(t1, t2);
        };
        let team1IsOffense = prng.nextCoin();
        let initState = MatchSimulator.initState(match.aura, team1Init, team2Init, team1IsOffense, prng, seed);
        #inProgress(initState);
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

    private func getMatchGroupOrNull(matchGroupId : Nat32) : ?MatchGroup {
        let matchGroupKey = {
            hash = matchGroupId;
            key = matchGroupId;
        };
        Trie.get(matchGroups, matchGroupKey, Nat32.equal);
    };

    private func addOrUpdateMatchGroup(matchGroupId : Nat32, matchGroup : MatchGroup) {
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
        match : Stadium.Match,
        options : Stadium.MatchOptions,
    ) : { #ok : Stadium.Match; #teamNotInMatch } {

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
