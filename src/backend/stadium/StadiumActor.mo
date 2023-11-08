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
import CommonUtil "../Util";
import League "../League";
import IterTools "mo:itertools/Iter";

actor class StadiumActor(leagueId : Principal) : async Stadium.StadiumActor = this {
    type MatchGroup = Stadium.MatchGroup;
    type MatchTeam = Stadium.MatchTeam;
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
    type BuildDivisionError = {
        #matchGroupErrors : [Stadium.ScheduleMatchGroupError];
        #teamFetchError : Text;
        #playerFetchError : Text;
        #noMatchGroupsSpecified;
    };
    type BuildDivisionResult = CommonUtil.Result<[MatchGroupToBeScheduled], BuildDivisionError>;

    type BuildMatchGroupError = {
        #matchErrors : [Stadium.ScheduleMatchError];
        #noMatchesSpecified;
    };
    type BuildMatchGroupResult = CommonUtil.Result<MatchGroupToBeScheduled, BuildMatchGroupError>;
    type BuildMatchError = {
        #teamNotFound : Stadium.TeamIdOrBoth;
    };
    type BuildMatchResult = {
        #ok : Stadium.Match;
        #error : BuildMatchError;
    };
    type MatchGroupId = Nat32;
    type StableSeasonSchedule = {
        var divisions : Trie.Trie<Principal, [MatchGroupId]>;
        var matchGroups : Trie.Trie<Nat32, MatchGroup>;
    };
    type MatchGroupToBeScheduled = {
        time : Time.Time;
        matches : [Stadium.Match];
    };

    stable var seasonScheduleOrNull : ?StableSeasonSchedule = null;

    public query func getMatchGroup(id : Nat32) : async ?Stadium.MatchGroupWithId {
        switch (getMatchGroupOrNull(id)) {
            case (null) return null;
            case (?m) {
                ?{
                    m with id = id;
                };
            };
        };
    };

    public query func getSeasonSchedule() : async ?Stadium.SeasonSchedule {
        switch (seasonScheduleOrNull) {
            case (null) return null;
            case (?s) {
                let divisions = Buffer.Buffer<Stadium.DivisionSchedule>(Trie.size(s.divisions));
                for ((divisionId, matchGroupIds) in Trie.iter(s.divisions)) {
                    let matchGroups = matchGroupIds
                    |> Array.map(
                        _,
                        func(matchGroupId : Nat32) : Stadium.MatchGroupWithId {
                            switch (getMatchGroupOrNull(matchGroupId)) {
                                case (null) Debug.trap("Match group " # Nat32.toText(matchGroupId) # " not found");
                                case (?m) {
                                    {
                                        m with
                                        id = matchGroupId;
                                    };
                                };
                            };
                        },
                    );
                    divisions.add({
                        id = divisionId;
                        matchGroups = matchGroups;
                    });
                };
                ?{
                    divisions = Buffer.toArray(divisions);
                };
            };
        };
    };

    public shared ({ caller }) func scheduleSeason(request : Stadium.ScheduleSeasonRequest) : async Stadium.ScheduleSeasonResult {
        assertLeague(caller);
        switch (seasonScheduleOrNull) {
            case (null)();
            case (?_) return #alreadyScheduled;
        };
        if (request.divisions.size() < 1) {
            return #noDivisionSpecified;
        };
        let results = Buffer.Buffer<CommonUtil.Result<(Principal, [MatchGroupToBeScheduled]), Stadium.ScheduleDivisionErrorResult>>(request.divisions.size());
        for (division in Iter.fromArray(request.divisions)) {
            let result = await* buildDivisionMatchGroups(division);
            switch (result) {
                case (#ok(matchGroups)) {
                    results.add(#ok((division.id, matchGroups)));
                };
                case (#error(error)) {
                    results.add(#error({ id = division.id; error }));
                };
            };
        };

        let divisionsToBeScheduled = switch (CommonUtil.allOkOrError<(Principal, [MatchGroupToBeScheduled]), Stadium.ScheduleDivisionErrorResult>(results.vals())) {
            case (#ok(matchGroupsToBeScheduled)) matchGroupsToBeScheduled;
            case (#error(errors)) return #divisionErrors(errors);
        };

        // Only schedule if all divisions were successful
        var matchGroups = Trie.empty<Nat32, MatchGroup>();
        var divisionMatchGroupMap = Trie.empty<Principal, [MatchGroupId]>();
        for ((divisionId, matchesToBeScheduled) in divisionsToBeScheduled.vals()) {
            let divisionMatchGroupIds = Buffer.Buffer<MatchGroupId>(matchesToBeScheduled.size());
            for (matchGroupToBeScheduled in Iter.fromArray(matchesToBeScheduled)) {
                let matchGroupId = Nat32.fromNat(Trie.size(matchGroups) + 1);
                divisionMatchGroupIds.add(matchGroupId);
                let timeDiff : Time.Time = matchGroupToBeScheduled.time - Time.now();
                let natTimeDiff = if (timeDiff < 0) {
                    1;
                } else {
                    Int.abs(timeDiff);
                };
                let startTimerId = Timer.setTimer(
                    #nanoseconds(natTimeDiff),
                    func() : async () {
                        await tickMatchGroupCallback(matchGroupId);
                    },
                );

                let matchGroup : Stadium.MatchGroup = {
                    time = matchGroupToBeScheduled.time;
                    matches = matchGroupToBeScheduled.matches;
                    state = #notStarted({
                        startTimerId = startTimerId;
                    });
                };
                let matchGroupKey = {
                    key = matchGroupId;
                    hash = matchGroupId;
                };
                let (newMatchGroups, _) = Trie.put(matchGroups, matchGroupKey, Nat32.equal, matchGroup);
                matchGroups := newMatchGroups;
            };

            let divisionKey = {
                key = divisionId;
                hash = Principal.hash(divisionId);
            };
            let (newDivisionMatchGroupMap, _) = Trie.put(divisionMatchGroupMap, divisionKey, Principal.equal, Buffer.toArray(divisionMatchGroupIds));
            divisionMatchGroupMap := newDivisionMatchGroupMap;

        };
        seasonScheduleOrNull := ?{
            var divisions = divisionMatchGroupMap;
            var matchGroups = matchGroups;
        };
        #ok;
    };

    public shared ({ caller }) func tickMatchGroup(matchGroupId : Nat32) : async Stadium.TickMatchGroupResult {
        let ?matchGroup = getMatchGroupOrNull(matchGroupId) else return #matchGroupNotFound;
        let matchGroupState : Stadium.InProgressMatchGroupState = switch (matchGroup.state) {
            case (#notStarted(notStartedState)) {
                let seedBlob = await Random.blob();
                let prng = CommonUtil.buildPrng(seedBlob);
                Timer.cancelTimer(notStartedState.startTimerId); // Cancel timer before making new one
                let tickTimerId = startTickTimer(matchGroupId);
                let startedMatches = Buffer.Buffer<Stadium.StartedMatchState>(matchGroup.matches.size());
                for (match in Iter.fromArray(matchGroup.matches)) {
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
                    currentSeed = prng.getCurrentSeed();
                };
            };
            case (#completed(_)) return #completed;
            case (#inProgress(g)) g;
        };
        let prng = PseudoRandomX.LinearCongruentialGenerator(matchGroupState.currentSeed);
        let newState : Stadium.StartedMatchGroupState = switch (tickMatches(prng, matchGroup.matches, matchGroupState.matches)) {
            case (#completed(completedMatches)) {
                // Cancel tick timer before disposing of timer id
                Timer.cancelTimer(matchGroupState.tickTimerId);

                #completed({
                    matchGroupState with
                    matches = completedMatches;
                    currentSeed = prng.getCurrentSeed();
                });
            };
            case (#inProgress(newMatches)) {
                #inProgress({
                    matchGroupState with
                    matches = newMatches;
                    currentSeed = prng.getCurrentSeed();
                });
            };
        };
        updateMatchGroupState({ matchGroup with id = matchGroupId }, newState);
        switch (newState) {
            case (#completed(_)) #completed;
            case (#inProgress(_)) #inProgress;
        };
    };

    public shared ({ caller }) func resetTickTimer(matchGroupId : Nat32) : async Stadium.ResetTickTimerResult {
        let ?matchGroup = getMatchGroupOrNull(matchGroupId) else return #matchGroupNotFound;
        switch (matchGroup.state) {
            case (#notStarted(notStartedState)) #matchGroupNotStarted;
            case (#completed(_)) return #matchGroupComplete;
            case (#inProgress(inProgressState)) {
                Timer.cancelTimer(inProgressState.tickTimerId);
                let newTickTimerId = startTickTimer(matchGroupId);
                let newState = #inProgress({
                    inProgressState with
                    tickTimerId = newTickTimerId;
                });
                updateMatchGroupState({ matchGroup with id = matchGroupId }, newState);
                #ok;
            };
        };
    };

    private func startTickTimer(matchGroupId : Nat32) : Timer.TimerId {
        Timer.recurringTimer(
            #seconds(5),
            func() : async () {
                await tickMatchGroupCallback(matchGroupId);
            },
        );
    };

    private func updateMatchGroupState(matchGroup : Stadium.MatchGroupWithId, newState : Stadium.MatchGroupState) : () {
        let newMatchGroup = {
            matchGroup with
            state = newState;
        };

        let ?schedule = seasonScheduleOrNull else Prelude.unreachable();
        let matchGroupKey = {
            hash = matchGroup.id;
            key = matchGroup.id;
        };
        let (newMatchGroups, _) = Trie.replace(schedule.matchGroups, matchGroupKey, Nat32.equal, ?newMatchGroup);
        schedule.matchGroups := newMatchGroups;
    };

    private func buildDivisionMatchGroups(request : Stadium.ScheduleDivisionRequest) : async* BuildDivisionResult {
        if (request.matchGroups.size() < 1) {
            return #error(#noMatchGroupsSpecified);
        };
        let divisionActor = actor (Principal.toText(request.id)) : League.LeagueActor;
        let teams = try {
            await divisionActor.getTeams();
        } catch (err) {
            return #error(#teamFetchError(Error.message(err)));
        };
        let allPlayers = try {
            await PlayerLedgerActor.getAllPlayers();
        } catch (err) {
            return #error(#playerFetchError(Error.message(err)));
        };
        let buildMatchGroupResults = request.matchGroups
        |> Array.map<Stadium.ScheduleMatchGroupRequest, BuildMatchGroupResult>(
            _,
            func(matchGroupRequest : Stadium.ScheduleMatchGroupRequest) : BuildMatchGroupResult {
                buildMatchGroup(matchGroupRequest, allPlayers, teams);
            },
        );
        switch (CommonUtil.allOkOrError(buildMatchGroupResults.vals())) {
            case (#ok(matchGroups)) #ok(matchGroups);
            case (#error(errors)) #error(#matchGroupErrors(errors));
        };
    };

    private func buildMatchGroup(
        request : Stadium.ScheduleMatchGroupRequest,
        players : [PlayerWithId],
        teams : [TeamWithId],
    ) : BuildMatchGroupResult {
        if (request.matches.size() < 1) {
            return #error(#noMatchesSpecified);
        };
        let results = request.matches
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(m : Stadium.ScheduleMatchRequest) : BuildMatchResult {
                buildMatch(m, players, teams);
            },
        );
        switch (CommonUtil.allOkOrError(results)) {
            case (#ok(matches)) #ok({
                time = request.startTime;
                matches = matches;
            });
            case (#error(errors)) return #error(#matchErrors(errors));
        };
    };

    private func buildMatch(
        request : Stadium.ScheduleMatchRequest,
        players : [PlayerWithId],
        teams : [TeamWithId],
    ) : BuildMatchResult {
        let team1OrNull = Array.find(teams, func(t : TeamWithId) : Bool = t.id == request.team1Id);
        let team2OrNull = Array.find(teams, func(t : TeamWithId) : Bool = t.id == request.team2Id);
        switch ((team1OrNull, team2OrNull)) {
            case (null, null) return #error(#teamNotFound(#bothTeams));
            case (null, ?_) return #error(#teamNotFound(#team1));
            case (?_, null) return #error(#teamNotFound(#team2));
            case (?t1, ?t2) {
                let getPlayers = func(teamId : Principal) : [Stadium.MatchPlayer] {
                    return players
                    |> Array.filter(_, func(p : PlayerWithId) : Bool = p.teamId == ?teamId)
                    |> Array.map(
                        _,
                        func(p : PlayerWithId) : Stadium.MatchPlayer {
                            return {
                                id = p.id;
                                name = p.name;
                            };
                        },
                    );
                };
                let team1 = {
                    t1 with
                    predictionVotes = 0;
                    players = getPlayers(t1.id);
                };
                let team2 = {
                    t2 with
                    predictionVotes = 0;
                    players = getPlayers(t2.id);
                };
                #ok({
                    team1 = team1;
                    team2 = team2;
                    offerings = request.offerings;
                    aura = request.aura;
                    state = #notStarted;
                });
            };
        };
    };

    private func tickMatchGroupCallback(matchGroupId : Nat32) : async () {
        let message = try {
            switch (await tickMatchGroup(matchGroupId)) {
                case (#matchGroupNotFound) "Failed to tick match group: Match Group not found";
                case (#completed(_)) "Failed to tick match group: Match Group completed";
                case (#inProgress(_)) "Ticked match group: " # Nat32.toText(matchGroupId);
            };
        } catch (err) {
            "Failed to tick match group: " # Error.message(err);
        };
        Debug.print("Tick Match Group Callback Result - " # message);
    };

    private func tickMatches(prng : Prng, matches : [Stadium.Match], matchStates : [Stadium.StartedMatchState]) : {
        #completed : [Stadium.CompletedMatchState];
        #inProgress : [Stadium.StartedMatchState];
    } {
        let completedMatchStates = Buffer.Buffer<Stadium.CompletedMatchState>(0);
        let newMatchStates = Buffer.Buffer<Stadium.StartedMatchState>(0);
        var matchIndex = 0;
        for (matchState in Iter.fromArray(matchStates)) {
            let match = matches[matchIndex]; // TODO safe indexing
            matchIndex += 1;
            let newMatchState = tickMatchState(match.team1, match.team2, prng, matchState);
            newMatchStates.add(newMatchState);
            switch (newMatchState) {
                case (#completed(completedState)) completedMatchStates.add(completedState);
                case (#inProgress(_)) {};
            };
        };
        if (completedMatchStates.size() == newMatchStates.size()) {
            // If all matches are complete, then complete the group
            #completed(Buffer.toArray(completedMatchStates));
        } else {
            #inProgress(Buffer.toArray(newMatchStates));
        };
    };

    private func tickMatchState(
        team1 : MatchSimulator.TeamInfo,
        team2 : MatchSimulator.TeamInfo,
        prng : Prng,
        state : Stadium.StartedMatchState,
    ) : Stadium.StartedMatchState {
        switch (state) {
            case (#completed(completedState)) #completed(completedState);
            case (#inProgress(s)) {
                MatchSimulator.tick(team1, team2, s, prng);
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
        let initState = MatchSimulator.initState(match.aura, team1Init, team2Init, team1IsOffense, prng);
        #inProgress(initState);
    };

    private func createTeamInit(matchGroupId : Nat32, team : Stadium.MatchTeam) : async ?MatchSimulator.TeamInitData {
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
            championId = options.championId;
        };
    };

    private func getMatchGroupOrNull(matchGroupId : Nat32) : ?MatchGroup {
        let ?schedule = seasonScheduleOrNull else return null;
        let matchGroupKey = {
            hash = matchGroupId;
            key = matchGroupId;
        };
        Trie.get(schedule.matchGroups, matchGroupKey, Nat32.equal);
    };

    private func assertLeague(caller : Principal) {
        if (caller != leagueId) {
            Debug.trap("Only the league can schedule matches");
        };
    };
};
