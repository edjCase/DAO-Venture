import Player "../models/Player";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import StadiumTypes "../stadium/Types";
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
import LeagueTypes "../league/Types";
import IterTools "mo:itertools/Iter";
import Offering "../models/Offering";
import MatchAura "../models/MatchAura";
import Team "../models/Team";

actor class StadiumActor(leagueId : Principal) : async StadiumTypes.StadiumActor = this {
    type MatchGroup = StadiumTypes.MatchGroup;
    type MatchTeam = StadiumTypes.MatchTeam;
    type Player = Player.Player;
    type PlayerWithId = Player.PlayerWithId;
    type PlayerState = StadiumTypes.PlayerState;
    type FieldPosition = Player.FieldPosition;
    type Offering = Offering.Offering;
    type MatchAura = MatchAura.MatchAura;
    type Prng = PseudoRandomX.PseudoRandomGenerator;
    type TeamWithId = Team.TeamWithId;
    type StartMatchResult = {
        #inProgress : StadiumTypes.InProgressMatchState;
        #completed : StadiumTypes.CompletedMatchState;
    };

    type BuildMatchGroupError = {
        #matchErrors : [StadiumTypes.ScheduleMatchError];
        #noMatchesSpecified;
    };
    type BuildMatchGroupResult = BuildMatchGroupError or {
        #ok : MatchGroupToBeScheduled;
    };
    type BuildMatchError = {
        #teamNotFound : Team.TeamIdOrBoth;
    };
    type BuildMatchResult = BuildMatchError or {
        #ok : StadiumTypes.Match;
    };
    type MatchGroupId = Nat;
    type StableSeasonSchedule = {
        var matchGroups : Trie.Trie<Nat32, MatchGroup>;
    };
    type MatchGroupToBeScheduled = {
        id : Nat;
        time : Time.Time;
        matches : [StadiumTypes.Match];
    };

    stable var matchGroups = Trie.empty<Nat, MatchGroup>();

    public query func getMatchGroup(id : Nat) : async ?StadiumTypes.MatchGroupWithId {
        switch (getMatchGroupOrNull(id)) {
            case (null) return null;
            case (?m) {
                ?{
                    m with
                    id = id;
                };
            };
        };
    };

    public query func getMatchGroups() : async [StadiumTypes.MatchGroupWithId] {
        matchGroups
        |> Trie.iter(_)
        |> Iter.map(
            _,
            func(m : (Nat, StadiumTypes.MatchGroup)) : StadiumTypes.MatchGroupWithId = {
                m.1 with
                id = m.0;
            },
        )
        |> Iter.toArray(_);
    };

    public shared ({ caller }) func scheduleMatchGroup(
        request : StadiumTypes.ScheduleMatchGroupRequest
    ) : async StadiumTypes.ScheduleMatchGroupResult {
        assertLeague(caller);

        let leagueActor = actor (Principal.toText(leagueId)) : LeagueTypes.LeagueActor;
        let teams = try {
            await leagueActor.getTeams();
        } catch (err) {
            return #teamFetchError(Error.message(err));
        };
        let players = try {
            await PlayerLedgerActor.getAllPlayers();
        } catch (err) {
            return #playerFetchError(Error.message(err));
        };

        let matchGroup = switch (buildMatchGroup(request, players, teams)) {
            case (#ok(matchGroup)) matchGroup;
            case (#matchErrors(errors)) return #matchErrors(errors);
            case (#noMatchesSpecified) return #noMatchesSpecified;
        };

        let timeDiff : Time.Time = matchGroup.time - Time.now();
        let natTimeDiff = if (timeDiff < 0) {
            1;
        } else {
            Int.abs(timeDiff);
        };
        let matchGroupId = matchGroup.id;
        let startTimerId = Timer.setTimer(
            #nanoseconds(natTimeDiff),
            func() : async () {
                Debug.print("Starting match group " # Nat.toText(matchGroupId));
                await tickMatchGroupCallback(matchGroupId);
            },
        );

        let newMatchGroup : StadiumTypes.MatchGroupWithId = {
            id = matchGroup.id;
            time = matchGroup.time;
            matches = matchGroup.matches;
            state = #notStarted({
                startTimerId = startTimerId;
            });
        };
        addOrUpdateMatchGroup(newMatchGroup);

        #ok(newMatchGroup);
    };

    public shared ({ caller }) func tickMatchGroup(matchGroupId : Nat) : async StadiumTypes.TickMatchGroupResult {
        let ?matchGroup = getMatchGroupOrNull(matchGroupId) else return #matchGroupNotFound;
        switch (matchGroup.state) {
            case (#notStarted(state)) await* tickNotStartedMatchGroup({ matchGroup with id = matchGroupId }, state);
            case (#completed(_)) #completed;
            case (#inProgress(state)) await* tickInProgressMatchGroup({ matchGroup with id = matchGroupId }, state);
        };
    };

    public shared ({ caller }) func resetTickTimer(matchGroupId : Nat) : async StadiumTypes.ResetTickTimerResult {
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
                addOrUpdateMatchGroup({
                    matchGroup with
                    id = matchGroupId;
                    state = newState;
                });
                #ok;
            };
        };
    };

    private func tickInProgressMatchGroup(
        matchGroup : StadiumTypes.MatchGroupWithId,
        state : StadiumTypes.InProgressMatchGroupState,
    ) : async* StadiumTypes.TickMatchGroupResult {
        let prng = PseudoRandomX.LinearCongruentialGenerator(state.currentSeed);
        switch (tickMatches(prng, matchGroup.matches, state.matches)) {
            case (#completed(completedMatches)) {
                // Cancel tick timer before disposing of match group
                // NOTE: Should be canceled even if the onMatchGroupComplete fails, so it doesnt
                // just keep ticking. Can retrigger manually if needed after fixing the
                // issue
                Timer.cancelTimer(state.tickTimerId);
                let leagueActor = actor (Principal.toText(leagueId)) : LeagueTypes.LeagueActor;
                let onCompleteRequest : LeagueTypes.OnMatchGroupCompleteRequest = {
                    id = matchGroup.id;
                    matches = completedMatches;
                };
                let result = try {
                    await leagueActor.onMatchGroupComplete(onCompleteRequest);
                } catch (err) {
                    #onCompleteCallbackError(Error.message(err));
                };

                let errorMessage = switch (result) {
                    case (#ok) {
                        // Remove match group if successfully passed info to the league
                        let matchGroupKey = buildMatchGroupKey(matchGroup.id);
                        let (newMatchGroups, _) = Trie.remove(matchGroups, matchGroupKey, Nat.equal);
                        matchGroups := newMatchGroups;
                        return #completed;
                    };
                    case (#notAuthorized) "Failed: Not authorized to complete match group";
                    case (#matchGroupNotFound) "Failed: Match group not found - " # Nat.toText(matchGroup.id);
                    case (#seedGenerationError(err)) "Failed: Seed generation error - " # err;
                    case (#seasonNotOpen) "Failed: Season not open";
                    case (#onCompleteCallbackError(err)) "Failed: On complete callback error - " # err;
                };
                Debug.print("On Match Group Complete Result - " # errorMessage);
                // Stuck in a bad state. Can retry by a manual tick call
                #completed;
            };
            case (#inProgress(newMatches)) {
                addOrUpdateMatchGroup({
                    matchGroup with
                    id = matchGroup.id;
                    state = #inProgress({
                        state with
                        matches = newMatches;
                        currentSeed = prng.getCurrentSeed();
                    });
                });

                #inProgress;
            };
        };
    };

    private func tickNotStartedMatchGroup(
        matchGroup : StadiumTypes.MatchGroupWithId,
        state : StadiumTypes.NotStartedMatchGroupState,
    ) : async* StadiumTypes.TickMatchGroupResult {
        let leagueActor = actor (Principal.toText(leagueId)) : LeagueTypes.LeagueActor;
        let onStartResult = try {
            await leagueActor.onMatchGroupStart({
                id = matchGroup.id;
            });
        } catch (err) {
            return #onStartCallbackError(#unknown(Error.message(err)));
        };
        let onStartData = switch (onStartResult) {
            case (#ok(onStartData)) onStartData;
            case (#notAuthorized) return #onStartCallbackError(#notAuthorized);
            case (#matchGroupNotFound) return #onStartCallbackError(#matchGroupNotFound);
            case (#notScheduledYet) return #onStartCallbackError(#notScheduledYet);
            case (#alreadyStarted) return #onStartCallbackError(#alreadyStarted);
        };

        let seedBlob = await Random.blob();
        let prng = CommonUtil.buildPrng(seedBlob);
        Timer.cancelTimer(state.startTimerId); // Cancel timer before making new one
        let tickTimerId = startTickTimer(matchGroup.id);

        let startedMatches : [StadiumTypes.StartedMatchState] = onStartData.matches
        |> Iter.fromArray(_)
        |> IterTools.zip(_, Iter.fromArray(matchGroup.matches))
        |> Iter.map(
            _,
            func((startOrSkip, match) : (LeagueTypes.MatchStartOrSkipData, StadiumTypes.Match)) : StadiumTypes.StartedMatchState {
                let startData = switch (startOrSkip) {
                    case (#absentTeam(absentTeam)) return #completed(#absentTeam(absentTeam));
                    case (#allAbsent) return #completed(#allAbsent);
                    case (#start(data)) data;
                };

                let team1Init = createTeamInit(match.team1, startData.team1, prng);
                let team2Init = createTeamInit(match.team2, startData.team2, prng);
                let team1IsOffense = prng.nextCoin();
                let initState = MatchSimulator.initState(
                    startData.aura,
                    team1Init,
                    team2Init,
                    team1IsOffense,
                    prng,
                );

                #inProgress(initState);
            },
        )
        |> Iter.toArray(_);
        let inProgressState = {
            matches = startedMatches;
            tickTimerId = tickTimerId;
            currentSeed = prng.getCurrentSeed();
        };
        // Tick once to start the match
        await* tickInProgressMatchGroup(matchGroup, inProgressState);
    };

    private func startTickTimer(matchGroupId : Nat) : Timer.TimerId {
        Timer.recurringTimer(
            #seconds(5),
            func() : async () {
                await tickMatchGroupCallback(matchGroupId);
            },
        );
    };

    private func addOrUpdateMatchGroup(newMatchGroup : StadiumTypes.MatchGroupWithId) : () {
        let matchGroupKey = buildMatchGroupKey(newMatchGroup.id);
        let (newMatchGroups, _) = Trie.replace(matchGroups, matchGroupKey, Nat.equal, ?newMatchGroup);
        matchGroups := newMatchGroups;
    };

    private func buildMatchGroup(
        request : StadiumTypes.ScheduleMatchGroupRequest,
        players : [PlayerWithId],
        teams : [TeamWithId],
    ) : BuildMatchGroupResult {
        if (request.matches.size() < 1) {
            return #noMatchesSpecified;
        };
        let matches = Buffer.Buffer<StadiumTypes.Match>(10);
        let errorItems = Buffer.Buffer<BuildMatchError>(0);
        for (matchRequest in Iter.fromArray(request.matches)) {
            switch (buildMatch(matchRequest, players, teams)) {
                case (#ok(match)) matches.add(match);
                case (#teamNotFound(error)) errorItems.add(#teamNotFound(error));
            };
        };
        if (errorItems.size() > 0) {
            #matchErrors(Buffer.toArray(errorItems));
        } else {
            #ok({
                id = request.id;
                time = request.startTime;
                matches = Buffer.toArray(matches);
            });
        };
    };

    private func buildMatch(
        request : StadiumTypes.ScheduleMatchRequest,
        players : [PlayerWithId],
        teams : [TeamWithId],
    ) : BuildMatchResult {
        let team1OrNull = Array.find(teams, func(t : TeamWithId) : Bool = t.id == request.team1Id);
        let team2OrNull = Array.find(teams, func(t : TeamWithId) : Bool = t.id == request.team2Id);
        switch ((team1OrNull, team2OrNull)) {
            case (null, null) return #teamNotFound(#bothTeams);
            case (null, ?_) return #teamNotFound(#team1);
            case (?_, null) return #teamNotFound(#team2);
            case (?t1, ?t2) {
                let getPlayers = func(teamId : Principal) : [StadiumTypes.MatchPlayer] {
                    return players
                    |> Array.filter(_, func(p : PlayerWithId) : Bool = p.teamId == ?teamId)
                    |> Array.map(
                        _,
                        func(p : PlayerWithId) : StadiumTypes.MatchPlayer {
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
                let offerings = request.offerings
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(o : Offering) : Offering.OfferingWithMetaData {
                        let metaData = Offering.getMetaData(o);
                        {
                            offering = o;
                            name = metaData.name;
                            description = metaData.description;
                        };
                    },
                )
                |> Iter.toArray(_);
                let metaData = MatchAura.getMetaData(request.aura);
                let aura = {
                    aura = request.aura;
                    name = metaData.name;
                    description = metaData.description;
                };
                #ok({
                    team1 = team1;
                    team2 = team2;
                    offerings = offerings;
                    aura = aura;
                    state = #notStarted;
                });
            };
        };
    };

    private func tickMatchGroupCallback(matchGroupId : Nat) : async () {
        let message = try {
            switch (await tickMatchGroup(matchGroupId)) {
                case (#matchGroupNotFound) "Match Group not found";
                case (#onStartCallbackError(err)) "On start callback error: " # debug_show (err);
                case (#completed(_)) "Match Group completed";
                case (#inProgress(_)) return (); // Dont log normal tick
            };
        } catch (err) {
            "Failed to tick match group: " # Error.message(err);
        };
        Debug.print("Tick Match Group Callback Result - " # message);
    };

    private func tickMatches(prng : Prng, matches : [StadiumTypes.Match], matchStates : [StadiumTypes.StartedMatchState]) : {
        #completed : [LeagueTypes.CompletedMatch];
        #inProgress : [StadiumTypes.StartedMatchState];
    } {
        let completedMatchStates = Buffer.Buffer<LeagueTypes.CompletedMatch>(matches.size());
        let newMatchStates = Buffer.Buffer<StadiumTypes.StartedMatchState>(0);
        var matchIndex = 0;
        for (matchState in Iter.fromArray(matchStates)) {
            let match = matches[matchIndex]; // TODO safe indexing?
            matchIndex += 1;
            let newMatchState = tickMatchState(match.team1, match.team2, prng, matchState);
            newMatchStates.add(newMatchState);
            switch (newMatchState) {
                case (#completed(completedState)) {
                    let completedMatch : LeagueTypes.CompletedMatch = switch (completedState) {
                        case (#absentTeam(absentTeam)) #absentTeam(absentTeam);
                        case (#allAbsent) #allAbsent;
                        case (#played(playedState)) #played({
                            team1Score = playedState.team1.score;
                            team2Score = playedState.team2.score;
                            winner = playedState.winner;
                            log = playedState.log;
                        });
                        case (#stateBroken(brokenState)) #failed({
                            message = "Match in bad state: " # debug_show (brokenState);
                            log = brokenState.log;
                        });
                    };
                    completedMatchStates.add(completedMatch);
                };
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
        state : StadiumTypes.StartedMatchState,
    ) : StadiumTypes.StartedMatchState {
        switch (state) {
            case (#completed(completedState)) #completed(completedState);
            case (#inProgress(s)) {
                MatchSimulator.tick(team1, team2, s, prng);
            };
        };
    };

    private func createTeamInit(
        team : StadiumTypes.MatchTeam,
        startData : LeagueTypes.TeamStartData,
        prng : Prng,
    ) : MatchSimulator.TeamInitData {
        let players = Buffer.fromArray<PlayerWithId>(startData.players);
        switch (startData.offering) {
            case (#shuffleAndBoost) {
                let currentPositions : Buffer.Buffer<FieldPosition> = players
                |> Buffer.map(
                    _,
                    func(p : Player) : FieldPosition = p.position,
                );
                prng.shuffleBuffer(currentPositions);
                for (i in IterTools.range(0, players.size())) {
                    // TODO skills
                    let updatedPlayer = {
                        players.get(i) with
                        position = currentPositions.get(i)
                    };
                    players.put(i, updatedPlayer);
                };
            };
        };
        {
            team with
            players = Buffer.toArray(players);
            offering = startData.offering;
            championId = startData.championId;
        };
    };

    private func getMatchGroupOrNull(matchGroupId : Nat) : ?MatchGroup {
        let matchGroupKey = buildMatchGroupKey(matchGroupId);
        Trie.get(matchGroups, matchGroupKey, Nat.equal);
    };

    private func buildMatchGroupKey(matchGroupId : Nat) : {
        key : Nat;
        hash : Nat32;
    } {
        {
            hash = Nat32.fromNat(matchGroupId); // TODO better hash? shouldnt need more than 32 bits
            key = matchGroupId;
        };
    };

    private func assertLeague(caller : Principal) {
        if (caller != leagueId) {
            Debug.trap("Only the league can schedule matches");
        };
    };
};
