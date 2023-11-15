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

    type BuildMatchGroupError = {
        #matchErrors : [Stadium.ScheduleMatchError];
        #noMatchesSpecified;
    };
    type BuildMatchGroupResult = BuildMatchGroupError or {
        #ok : MatchGroupToBeScheduled;
    };
    type BuildMatchError = {
        #teamNotFound : Stadium.TeamIdOrBoth;
    };
    type BuildMatchResult = {
        #ok : Stadium.Match;
        #error : BuildMatchError;
    };
    type MatchGroupId = Nat32;
    type StableSeasonSchedule = {
        var matchGroups : Trie.Trie<Nat32, MatchGroup>;
    };
    type MatchGroupToBeScheduled = {
        id : Nat32;
        time : Time.Time;
        matches : [Stadium.Match];
    };

    stable var matchGroups = Trie.empty<Nat32, MatchGroup>();

    public query func getMatchGroup(id : Nat32) : async ?Stadium.MatchGroupWithId {
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

    public query func getMatchGroups() : async [Stadium.MatchGroupWithId] {
        matchGroups
        |> Trie.iter(_)
        |> Iter.map(
            _,
            func(m : (Nat32, Stadium.MatchGroup)) : Stadium.MatchGroupWithId = {
                m.1 with
                id = m.0;
            },
        )
        |> Iter.toArray(_);
    };

    public shared ({ caller }) func scheduleMatchGroup(
        request : Stadium.ScheduleMatchGroupRequest
    ) : async Stadium.ScheduleMatchGroupResult {
        assertLeague(caller);

        let leagueActor = actor (Principal.toText(leagueId)) : League.LeagueActor;
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
                Debug.print("Starting match group " # Nat32.toText(matchGroupId));
                await tickMatchGroupCallback(matchGroupId);
            },
        );

        let newMatchGroup : Stadium.MatchGroupWithId = {
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
        switch (tickMatches(prng, matchGroup.matches, matchGroupState.matches)) {
            case (#completed(completedMatches)) {
                // Cancel tick timer before disposing of match group
                // NOTE: Should be canceled even if the onMatchGroupComplete fails, so it doesnt
                // just keep ticking. Can retrigger manually if needed after fixing the
                // issue
                Timer.cancelTimer(matchGroupState.tickTimerId);
                let leagueActor = actor (Principal.toText(leagueId)) : League.LeagueActor;
                let onCompleteRequest : League.OnMatchGroupCompleteRequest = {
                    id = matchGroupId;
                    state = {
                        matchGroupState with
                        matches = completedMatches;
                    };
                };
                let result = try {
                    await leagueActor.onMatchGroupComplete(onCompleteRequest);
                } catch (err) {
                    #onCompleteCallbackError(Error.message(err));
                };

                let errorMessage = switch (result) {
                    case (#ok) {
                        // Remove match group if successfully passed info to the league
                        let matchGroupKey = {
                            hash = matchGroupId;
                            key = matchGroupId;
                        };
                        let (newMatchGroups, _) = Trie.remove(matchGroups, matchGroupKey, Nat32.equal);
                        matchGroups := newMatchGroups;
                        return #completed;
                    };
                    case (#notAuthorized) "Failed: Not authorized to complete match group";
                    case (#matchGroupNotFound) "Failed: Match group not found - " # Nat32.toText(matchGroupId);
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
                    id = matchGroupId;
                    state = #inProgress({
                        matchGroupState with
                        matches = newMatches;
                        currentSeed = prng.getCurrentSeed();
                    });
                });

                #inProgress;
            };
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
                addOrUpdateMatchGroup({
                    matchGroup with
                    id = matchGroupId;
                    state = newState;
                });
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

    private func addOrUpdateMatchGroup(newMatchGroup : Stadium.MatchGroupWithId) : () {
        let matchGroupKey = {
            hash = newMatchGroup.id;
            key = newMatchGroup.id;
        };
        let (newMatchGroups, _) = Trie.replace(matchGroups, matchGroupKey, Nat32.equal, ?newMatchGroup);
        matchGroups := newMatchGroups;
    };

    private func buildMatchGroup(
        request : Stadium.ScheduleMatchGroupRequest,
        players : [PlayerWithId],
        teams : [TeamWithId],
    ) : BuildMatchGroupResult {
        if (request.matches.size() < 1) {
            return #noMatchesSpecified;
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
                id = request.id;
                time = request.startTime;
                matches = matches;
            });
            case (#error(errors)) return #matchErrors(errors);
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
                let offerings = request.offerings
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(o : Offering) : Stadium.OfferingWithMetaData {
                        let metaData = Stadium.getOfferingMetaData(o);
                        {
                            offering = o;
                            name = metaData.name;
                            description = metaData.description;
                        };
                    },
                )
                |> Iter.toArray(_);
                let metaData = Stadium.getMatchAuraMetaData(request.aura);
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

    private func tickMatchGroupCallback(matchGroupId : Nat32) : async () {
        let message = try {
            switch (await tickMatchGroup(matchGroupId)) {
                case (#matchGroupNotFound) "Match Group not found";
                case (#completed(_)) "Match Group completed";
                case (#inProgress(_)) return (); // Dont log normal tick
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
        let team1InitOrNull = await createTeamInit(matchGroupId, match.team1, prng);
        let team2InitOrNull = await createTeamInit(matchGroupId, match.team2, prng);
        let (team1Init, team2Init) : (MatchSimulator.TeamInitData, MatchSimulator.TeamInitData) = switch (team1InitOrNull, team2InitOrNull) {
            case (null, null) return #completed(#allAbsent);
            case (null, ?_) return #completed(#absentTeam(#team1));
            case (?_, null) return #completed(#absentTeam(#team2));
            case (?t1, ?t2)(t1, t2);
        };
        let team1IsOffense = prng.nextCoin();
        let initState = MatchSimulator.initState(match.aura.aura, team1Init, team2Init, team1IsOffense, prng);
        #inProgress(initState);
    };

    private func createTeamInit(
        matchGroupId : Nat32,
        team : Stadium.MatchTeam,
        prng : Prng,
    ) : async ?MatchSimulator.TeamInitData {
        var teamPlayers = await PlayerLedgerActor.getTeamPlayers(?team.id);
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
        switch (options.offering) {
            case (#shuffleAndBoost) {
                let players = Buffer.fromArray<Player>(teamPlayers);
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
        ?{
            id = team.id;
            name = team.name;
            players = teamPlayers;
            offering = options.offering;
            championId = options.championId;
        };
    };

    private func getMatchGroupOrNull(matchGroupId : Nat32) : ?MatchGroup {
        let matchGroupKey = {
            hash = matchGroupId;
            key = matchGroupId;
        };
        Trie.get(matchGroups, matchGroupKey, Nat32.equal);
    };

    private func assertLeague(caller : Principal) {
        if (caller != leagueId) {
            Debug.trap("Only the league can schedule matches");
        };
    };
};
