import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Cycles "mo:base/ExperimentalCycles";
import IterTools "mo:itertools/Iter";
import Hash "mo:base/Hash";
import Player "../models/Player";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import StadiumTypes "../stadium/Types";
import Time "mo:base/Time";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Blob "mo:base/Blob";
import Order "mo:base/Order";
import Timer "mo:base/Timer";
import Token "mo:icrc1/ICRC1/Canisters/Token";
import PseudoRandomX "mo:random/PseudoRandomX";
import Types "../league/Types";
import Util "../Util";
import ScheduleBuilder "ScheduleBuilder";
import PlayerLedgerActor "canister:playerLedger";
import Team "../models/Team";
import TeamTypes "../team/Types";
import Season "../models/Season";
import MatchAura "../models/MatchAura";
import Offering "../models/Offering";
import TeamFactoryActor "canister:teamFactory";
import StadiumFactoryActor "canister:stadiumFactory";

actor LeagueActor {
    type TeamLedgerActor = Token.Token;
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var teams : Trie.Trie<Principal, Team.TeamWithLedgerId> = Trie.empty();
    stable var seasonStatus : Season.SeasonStatus = #notStarted;
    stable var stadiumIdOrNull : ?Principal = null;

    public query func getTeams() : async [TeamWithId] {
        Trie.toArray(
            teams,
            func(k : Principal, v : Team.TeamWithLedgerId) : TeamWithId = {
                id = k;
                name = v.name;
                logoUrl = v.logoUrl;
                ledgerId = v.ledgerId;
            },
        );
    };

    public query func getSeasonStatus() : async Season.SeasonStatus {
        seasonStatus;
    };

    public shared ({ caller }) func startSeason(request : Types.StartSeasonRequest) : async Types.StartSeasonResult {
        switch (seasonStatus) {
            case (#notStarted) {};
            case (#starting) return #alreadyStarted;
            case (#inProgress(_)) return #alreadyStarted;
            case (#completed(_)) return #alreadyStarted;
        };
        seasonStatus := #starting;

        let seedBlob = try {
            await Random.blob();
        } catch (err) {
            seasonStatus := #notStarted;
            return #seedGenerationError(Error.message(err));
        };
        let prng = PseudoRandomX.fromSeed(Blob.hash(seedBlob));

        let teamsArray = Trie.toArray(
            teams,
            func(k : Principal, v : Team.TeamWithLedgerId) : TeamWithId = {
                id = k;
                name = v.name;
                logoUrl = v.logoUrl;
                ledgerId = v.ledgerId;
            },
        );
        let buildResult = ScheduleBuilder.build(request, teamsArray, prng);

        let schedule : ScheduleBuilder.SeasonSchedule = switch (buildResult) {
            case (#ok(schedule)) schedule;
            case (#noTeams) {
                seasonStatus := #notStarted;
                return #noTeams;
            };
            case (#oddNumberOfTeams) {
                seasonStatus := #notStarted;
                return #oddNumberOfTeams;
            };
        };

        let getTeamInfo = func(teamId : Principal) : Season.TeamInfo {
            let ?team = Trie.get(teams, buildPrincipalKey(teamId), Principal.equal) else Debug.trap("Team not found: " # Principal.toText(teamId));
            {
                id = teamId;
                name = team.name;
                logoUrl = team.logoUrl;
            };
        };

        // Save full schedule, then try to start the first match groups
        let inProgressMatchGroups = schedule.matchGroups
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(mg : ScheduleBuilder.MatchGroup) : Season.InProgressSeasonMatchGroupVariant = #notScheduled({
                time = mg.time;
                matches = mg.matches
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(m : ScheduleBuilder.Match) : Season.NotScheduledMatch = {
                        team1 = getTeamInfo(m.team1Id);
                        team2 = getTeamInfo(m.team2Id);
                    },
                )
                |> Iter.toArray(_);
            }),
        )
        |> Iter.toArray(_);
        let inProgressSeason = {
            matchGroups = inProgressMatchGroups;
        };
        seasonStatus := #inProgress(inProgressSeason);

        // Get first match group to open
        let #notScheduled(firstMatchGroup) = inProgressMatchGroups[0] else Prelude.unreachable();

        scheduleMatchGroup(0, firstMatchGroup, inProgressSeason, prng);

        #ok;
    };

    public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {

        let nameAlreadyTaken = Trie.some(
            teams,
            func(k : Principal, v : Team.Team) : Bool = v.name == request.name,
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };
        let createTeamResult = try {
            await TeamFactoryActor.createTeamActor(request);
        } catch (err) {
            return #teamFactoryCallError(Error.message(err));
        };
        let teamInfo = switch (createTeamResult) {
            case (#ok(teamInfo)) teamInfo;
        };
        let team : Team.TeamWithLedgerId = {
            name = request.name;
            logoUrl = request.logoUrl;
            ledgerId = teamInfo.ledgerId;
        };
        let teamKey = buildPrincipalKey(teamInfo.id);
        let (newTeams, _) = Trie.put(teams, teamKey, Principal.equal, team);
        teams := newTeams;
        return #ok(teamInfo.id);
    };

    public shared ({ caller }) func mint(request : Types.MintRequest) : async Types.MintResult {
        // TODO
        // if (caller != leagueId) {
        //   return #notAuthorized;
        // }
        let ?team = Trie.get(teams, buildPrincipalKey(request.teamId), Principal.equal) else return #teamNotFound;
        let ledger = actor (Principal.toText(team.ledgerId)) : Token.Token;

        let transferResult = await ledger.mint({
            amount = request.amount;
            created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
            memo = null;
            to = {
                owner = request.teamId;
                subaccount = ?Principal.toBlob(caller);
            };
        });
        switch (transferResult) {
            case (#Ok(txIndex)) #ok(txIndex);
            case (#Err(error)) #transferError(error);
        };
    };

    public shared ({ caller }) func updateLeagueCanisters() : async () {
        await TeamFactoryActor.updateCanisters();
        await StadiumFactoryActor.updateCanisters();
    };

    public shared ({ caller }) func startMatchGroup(id : Nat) : async Types.StartMatchGroupResult {
        let #inProgress(season) = seasonStatus else return #matchGroupNotFound;
        let stadiumId = switch (await* getOrCreateStadium()) {
            case (#ok(id)) id;
            case (#stadiumCreationError(error)) return Debug.trap("Failed to create stadium: " # error);
        };

        // Get current match group
        let ?matchGroupVariant = Util.arrayGetSafe(
            season.matchGroups,
            id,
        ) else return #matchGroupNotFound;

        let scheduledMatchGroup : Season.ScheduledMatchGroup = switch (matchGroupVariant) {
            case (#notScheduled(_)) return #notScheduledYet;
            case (#inProgress(_)) return #alreadyStarted;
            case (#completed(_)) return #alreadyStarted;
            case (#scheduled(d)) d;
        };

        let allPlayers = await PlayerLedgerActor.getAllPlayers();
        let matchStartRequestBuffer = Buffer.Buffer<StadiumTypes.StartMatchRequest>(scheduledMatchGroup.matches.size());

        for (match in Iter.fromArray(scheduledMatchGroup.matches)) {
            let data = await* buildMatchStartData(id, match, allPlayers);
            matchStartRequestBuffer.add(data);
        };

        let startMatchGroupRequest : StadiumTypes.StartMatchGroupRequest = {
            id = id;
            matches = Buffer.toArray(matchStartRequestBuffer);
        };
        let stadiumActor = actor (Principal.toText(stadiumId)) : StadiumTypes.StadiumActor;
        let startResult = await stadiumActor.startMatchGroup(startMatchGroupRequest);

        switch (startResult) {
            case (#noMatchesSpecified) Debug.trap("No matches specified for match group " # Nat.toText(id));
            case (#matchErrors(errors)) return #matchErrors(errors);
            case (#ok) {
                let inProgressMatches = scheduledMatchGroup.matches
                |> Iter.fromArray(_)
                |> IterTools.zip(_, Iter.fromArray(startMatchGroupRequest.matches))
                |> Iter.map(
                    _,
                    func(match : (Season.ScheduledMatch, StadiumTypes.StartMatchRequest)) : Season.InProgressMatch {
                        {
                            team1 = match.0.team1;
                            team2 = match.0.team2;
                            aura = match.0.aura.aura;
                            result = switch (match.1.data) {
                                case (#start(startData)) {
                                    #started({
                                        team1Offering = startData.team1.offering;
                                        team2Offering = startData.team2.offering;
                                        team1ChampionId = startData.team1.championId;
                                        team2ChampionId = startData.team2.championId;
                                    });
                                };
                                case (#allAbsent) #allAbsent;
                                case (#absentTeam(absentTeam)) #absentTeam(absentTeam);
                            };
                        };
                    },
                )
                |> Iter.toArray(_);

                let newStatus : Season.InProgressSeasonMatchGroupVariant = #inProgress({
                    time = scheduledMatchGroup.time;
                    stadiumId = stadiumId;
                    matches = inProgressMatches;
                });
                // Update status to inProgress
                switch (updateInProgressMatchGroup(id, newStatus, season)) {
                    case (#ok)();
                    case (#matchGroupNotFound) return #matchGroupNotFound;
                };

                #ok;
            };
        };

    };

    public shared ({ caller }) func onMatchGroupComplete(
        request : Types.OnMatchGroupCompleteRequest
    ) : async Types.OnMatchGroupCompleteResult {
        Debug.print("On Match group complete called for: " # Nat.toText(request.id));
        let #inProgress(season) = seasonStatus else return #seasonNotOpen;
        let ?stadiumId = stadiumIdOrNull else return #notAuthorized;
        if (caller != stadiumId) {
            return #notAuthorized;
        };

        let seed = try {
            await Random.blob();
        } catch (err) {
            return #seedGenerationError(Error.message(err));
        };
        let prng = PseudoRandomX.fromSeed(Blob.hash(seed));

        // Get current match group
        let ?matchGroup = Util.arrayGetSafe<Season.InProgressSeasonMatchGroupVariant>(
            season.matchGroups,
            request.id,
        ) else return #matchGroupNotFound;
        let inProgressMatchGroup = switch (matchGroup) {
            case (#inProgress(matchGroupState)) matchGroupState;
            case (_) return #matchGroupNotInProgress;
        };

        let completedMatches : [Season.CompletedMatch] = IterTools.zip(
            Iter.fromArray(inProgressMatchGroup.matches),
            Iter.fromArray(request.matches),
        )
        |> Iter.map(
            _,
            func((inProgressMatch : Season.InProgressMatch, completedMatch : Types.CompletedMatch)) : Season.CompletedMatch {
                {
                    team1 = inProgressMatch.team1;
                    team2 = inProgressMatch.team2;
                    log = completedMatch.log;
                    result = switch (completedMatch.result) {
                        case (#allAbsent) #allAbsent;
                        case (#absentTeam(#team1)) #absentTeam(#team1);
                        case (#absentTeam(#team2)) #absentTeam(#team2);
                        case (#played(state)) #played({
                            team1 = state.team1;
                            team2 = state.team2;
                            winner = state.winner;
                        });
                        case (#failed(failedState)) #failed(failedState.message);
                    };
                };
            },
        )
        |> Iter.toArray(_);

        // Update status to completed
        let updatedMatchGroup : Season.CompletedMatchGroup = {
            time = inProgressMatchGroup.time;
            matches = completedMatches;
        };

        switch (updateInProgressMatchGroup(request.id, #completed(updatedMatchGroup), season)) {
            case (#ok)();
            case (#matchGroupNotFound) return #matchGroupNotFound;
        };

        // Get next match group to schedule
        let nextMatchGroupId = request.id + 1;
        let ?nextMatchGroup = Util.arrayGetSafe<Season.InProgressSeasonMatchGroupVariant>(
            season.matchGroups,
            nextMatchGroupId,
        ) else {
            // Season is over, cant find more match groups
            ignore await closeSeason(); // TODO how to not await this?
            return #ok;
        };
        switch (nextMatchGroup) {
            case (#notScheduled(matchGroup)) {
                // Schedule next match group
                scheduleMatchGroup(nextMatchGroupId, matchGroup, season, prng);
            };
            case (_) {
                // TODO
                // Anything else is a bad state
                // Print out error, but don't fail the call
                Debug.print("Unable to schedule next match group " # Nat.toText(nextMatchGroupId) # " because it is not in the correct state: " # debug_show (nextMatchGroup));
            };
        };
        #ok;
    };

    public shared ({ caller }) func closeSeason() : async Types.CloseSeasonResult {
        let #inProgress(inProgressSeason) = seasonStatus else return #seasonNotOpen;
        let completedMatchGroups = switch (buildCompletedMatchGroups(inProgressSeason)) {
            case (#ok(completedMatchGroups)) completedMatchGroups;
            case (#matchGroupsNotComplete) return #seasonInProgress;
        };
        let teamStandings = calculateTeamStandings(completedMatchGroups);
        let completedTeams = Trie.toArray(
            teams,
            func(k : Principal, v : Team.Team) : Season.CompletedSeasonTeam {
                let ?standingInfo = Trie.get(teamStandings, buildPrincipalKey(k), Principal.equal) else Debug.trap("Team not found in standings: " # Principal.toText(k));
                {
                    id = k;
                    name = v.name;
                    logoUrl = v.logoUrl;
                    standing = standingInfo.standing;
                    wins = standingInfo.wins;
                    losses = standingInfo.losses;
                };
            },
        );
        seasonStatus := #completed({
            teams = completedTeams;
            matchGroups = completedMatchGroups;
        });
        #ok;
    };

    private func scheduleMatchGroup(
        matchGroupId : Nat,
        matchGroup : Season.NotScheduledMatchGroup,
        inProgressSeason : Season.InProgressSeason,
        prng : Prng,
    ) : () {
        let timeDiff = matchGroup.time - Time.now();
        Debug.print("Scheduling match group " # Nat.toText(matchGroupId) # " in " # Int.toText(timeDiff) # " nanoseconds");
        let duration = if (timeDiff <= 0) {
            // Schedule immediately
            #nanoseconds(0);
        } else {
            #nanoseconds(Int.abs(timeDiff));
        };
        let timerId = Timer.setTimer(
            duration,
            func() : async () {
                let result = try {
                    await startMatchGroup(matchGroupId);
                } catch (err) {
                    Debug.print("Match group '" # Nat.toText(matchGroupId) # "' start callback failed: " # Error.message(err));
                    return;
                };
                let message = switch (result) {
                    case (#ok) "Match group started";
                    case (#matchGroupNotFound) "Match group not found";
                    case (#notAuthorized) "Not authorized";
                    case (#notScheduledYet) "Match group not scheduled yet";
                    case (#alreadyStarted) "Match group already started";
                    case (#matchErrors(errors)) "Match group errors: " # debug_show (errors);
                };
                Debug.print("Match group '" #Nat.toText(matchGroupId) # "' start callback: " # message);
            },
        );
        let scheduledMatchGroup : Season.ScheduledMatchGroup = {
            time = matchGroup.time;
            timerId = timerId;
            matches = matchGroup.matches
            |> Iter.fromArray(_)
            |> Iter.map(
                _,
                func(m : Season.NotScheduledMatch) : Season.ScheduledMatch {
                    {
                        team1 = m.team1;
                        team2 = m.team2;
                        offerings = getRandomOfferings(4);
                        aura = getRandomMatchAura(prng);
                    };
                },
            )
            |> Iter.toArray(_);
        };
        let status = #scheduled(scheduledMatchGroup);
        switch (updateInProgressMatchGroup(matchGroupId, status, inProgressSeason)) {
            case (#ok)();
            case (#matchGroupNotFound) Debug.trap("Match group not found: " # Nat.toText(matchGroupId));
        };
    };

    private func updateInProgressMatchGroup(
        matchGroupId : Nat,
        updatedMatchGroup : Season.InProgressSeasonMatchGroupVariant,
        inProgressSeason : Season.InProgressSeason,
    ) : { #ok; #matchGroupNotFound } {

        let ?newMatchGroups = Util.arrayUpdateElementSafe<Season.InProgressSeasonMatchGroupVariant>(
            inProgressSeason.matchGroups,
            matchGroupId,
            updatedMatchGroup,
        ) else return #matchGroupNotFound;

        seasonStatus := #inProgress({
            inProgressSeason with
            matchGroups = newMatchGroups;
        });
        #ok;
    };

    private func buildMatchStartData(
        matchGroupId : Nat,
        match : Season.ScheduledMatch,
        allPlayers : [Player.PlayerWithId],
    ) : async* StadiumTypes.StartMatchRequest {
        let team1InitOrNull = await* buildTeamInitData(matchGroupId, match.team1, allPlayers);
        let team2InitOrNull = await* buildTeamInitData(matchGroupId, match.team2, allPlayers);
        let data = switch (team1InitOrNull, team2InitOrNull) {
            case (#ok(t1), #ok(t2)) {
                #start({
                    team1 = t1;
                    team2 = t2;
                    aura = match.aura.aura;
                });
            };
            case (#ok(_), #noVotes) #absentTeam(#team2);
            case (#noVotes, #ok(_)) #absentTeam(#team1);
            case (#noVotes, #noVotes) #allAbsent;
        };
        {
            team1 = match.team1;
            team2 = match.team2;
            data = data;
        };
    };

    private func buildTeamInitData(
        matchGroupId : Nat,
        team : Season.TeamInfo,
        allPlayers : [Player.PlayerWithId],
    ) : async* {
        #ok : StadiumTypes.TeamStartData;
        #noVotes;
    } {
        let teamActor = actor (Principal.toText(team.id)) : TeamTypes.TeamActor;
        let options = try {
            // Get match options from the team itself
            let result : TeamTypes.GetMatchGroupVoteResult = await teamActor.getMatchGroupVote(matchGroupId);
            switch (result) {
                case (#noVotes) return #noVotes;
                case (#ok(o)) o;
                case (#notAuthorized) return Debug.trap("League is not authorized to get match options from team: " # Principal.toText(team.id));
            };
        } catch (err : Error.Error) {
            return Debug.trap("Failed to get team '" # Principal.toText(team.id) # "': " # Error.message(err));
        };
        let teamPlayers = allPlayers
        |> Iter.fromArray(_)
        |> Iter.filter(_, func(p : Player.PlayerWithId) : Bool = p.teamId == ?team.id)
        |> Iter.toArray(_);
        #ok({
            id = team.id;
            name = team.name;
            logoUrl = team.logoUrl;
            offering = options.offering;
            championId = options.championId;
            players = teamPlayers;
        });
    };

    private func getOrCreateStadium() : async* {
        #ok : Principal;
        #stadiumCreationError : Text;
    } {
        switch (stadiumIdOrNull) {
            case (null)();
            case (?id) return #ok(id);
        };
        let createStadiumResult = try {
            await StadiumFactoryActor.createStadiumActor();
        } catch (err) {
            return #stadiumCreationError(Error.message(err));
        };
        switch (createStadiumResult) {
            case (#ok(id)) {
                stadiumIdOrNull := ?id;
                #ok(id);
            };
            case (#stadiumCreationError(error)) return #stadiumCreationError(error);
        };
    };

    private func buildCompletedMatchGroups(
        season : Season.InProgressSeason
    ) : { #ok : [Season.CompletedMatchGroup]; #matchGroupsNotComplete } {
        let completedMatchGroups = Buffer.Buffer<Season.CompletedMatchGroup>(season.matchGroups.size());
        for (matchGroup in Iter.fromArray(season.matchGroups)) {
            let completedMatchGroup = switch (matchGroup) {
                case (#completed(completedMatchGroup)) completedMatchGroup;
                case (#notScheduled(notScheduledMatchGroup)) return #matchGroupsNotComplete;
                case (#scheduled(scheduledMatchGroup)) return #matchGroupsNotComplete;
                case (#inProgress(inProgressMatchGroup)) return #matchGroupsNotComplete;
            };
            completedMatchGroups.add(completedMatchGroup);
        };
        #ok(Buffer.toArray(completedMatchGroups));
    };

    type TeamSeasonStanding = {
        wins : Nat;
        losses : Nat;
        totalScore : Int;
        standing : Nat;
    };

    private func calculateTeamStandings(
        matchGroups : [Season.CompletedMatchGroup]
    ) : Trie.Trie<Principal, TeamSeasonStanding> {
        var teamScores = Trie.empty<Principal, TeamSeasonStanding>();
        let updateTeamScore = func(
            teamId : Principal,
            score : Int,
            won : Bool,
        ) : () {

            let teamKey = {
                key = teamId;
                hash = Principal.hash(teamId);
            };
            let currentScore = switch (Trie.get(teamScores, teamKey, Principal.equal)) {
                case (null) {
                    {
                        wins = 0;
                        losses = 0;
                        totalScore = 0;
                    };
                };
                case (?score) score;
            };
            // Update with +1
            let (newTeamScores, _) = Trie.put<Principal, TeamSeasonStanding>(
                teamScores,
                teamKey,
                Principal.equal,
                {
                    wins = if (won) currentScore.wins + 1 else currentScore.wins;
                    losses = if (won) currentScore.losses else currentScore.losses + 1;
                    totalScore = currentScore.totalScore + score;
                    standing = 0;
                },
            );
            teamScores := newTeamScores;
        };

        // Populate scores
        label f1 for (matchGroup in Iter.fromArray(matchGroups)) {
            label f2 for (match in Iter.fromArray(matchGroup.matches)) {
                switch (match.result) {
                    case (#allAbsent or #failed(_)) {
                        updateTeamScore(match.team1.id, 0, false);
                        updateTeamScore(match.team2.id, 0, false);
                    };
                    case (#absentTeam(#team1)) {
                        updateTeamScore(match.team1.id, 0, false);
                        updateTeamScore(match.team2.id, 0, true);
                    };
                    case (#absentTeam(#team2)) {
                        updateTeamScore(match.team1.id, 0, true);
                        updateTeamScore(match.team2.id, 0, false);
                    };
                    case (#played(state)) {
                        updateTeamScore(match.team1.id, state.team1.score, state.winner == #team1);
                        updateTeamScore(match.team2.id, state.team2.score, state.winner == #team2);
                    };
                };
            };
        };
        teamScores;
    };

    private func buildPrincipalKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };

    private func arrayToIdTrie<T>(items : [T], getId : (T) -> Nat32) : Trie.Trie<Nat32, T> {
        var trie = Trie.empty<Nat32, T>();
        for (item in Iter.fromArray(items)) {
            let id = getId(item);
            let key = {
                key = id;
                hash = id;
            };
            let (newTrie, _) = Trie.put(trie, key, Nat32.equal, item);
            trie := newTrie;
        };
        trie;
    };

    private func getRandomOfferings(count : Nat) : [Offering.OfferingWithMetaData] {
        // TODO
        [
            #shuffleAndBoost
        ]
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(o : Offering.Offering) : Offering.OfferingWithMetaData {
                { Offering.getMetaData(o) with offering = o };
            },
        )
        |> Iter.toArray(_);
    };

    private func getRandomMatchAura(prng : Prng) : MatchAura.MatchAuraWithMetaData {
        // TODO
        let auras = Buffer.fromArray<MatchAura.MatchAura>([
            #lowGravity,
            #explodingBalls,
            #fastBallsHardHits,
            #moreBlessingsAndCurses,
        ]);
        prng.shuffleBuffer(auras);
        let aura = auras.get(0);
        {
            MatchAura.getMetaData(aura) with
            aura = aura;
        };
    };

};
