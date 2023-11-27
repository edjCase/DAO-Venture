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
import TeamActor "../team/TeamActor";
import { ic } "mo:ic";
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
import Token "mo:icrc1/ICRC1/Canisters/Token";
import ICRC1 "mo:icrc1/ICRC1";
import TimeZone "mo:datetime/TimeZone";
import LocalDateTime "mo:datetime/LocalDateTime";
import Components "mo:datetime/Components";
import DateTime "mo:datetime/DateTime";
import RandomX "mo:random/RandomX";
import PseudoRandomX "mo:random/PseudoRandomX";
import Types "../league/Types";
import Util "../Util";
import StadiumActor "../stadium/StadiumActor";
import ScheduleBuilder "ScheduleBuilder";
import PlayerLedgerActor "canister:playerLedger";
import Team "../models/Team";
import Season "../models/Season";
import MatchAura "../models/MatchAura";
import Offering "../models/Offering";

actor LeagueActor {
    type LedgerActor = Token.Token;
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var seasonStatus : Season.SeasonStatus = #notStarted;
    stable var stadiumIdOrNull : ?Principal = null;

    public query func getTeams() : async [TeamWithId] {
        Trie.toArray(
            teams,
            func(k : Principal, v : Team.Team) : TeamWithId = {
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
        let stadiumId = switch (await* getOrCreateStadium()) {
            case (#ok(id)) id;
            case (#stadiumCreationError(error)) return Debug.trap("Failed to create stadium: " # error);
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
            func(k : Principal, v : Team.Team) : TeamWithId = {
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

        // Save full schedule, then try to start the first match groups
        let inProgressMatchGroups = schedule.matchGroups
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(mg : ScheduleBuilder.MatchGroup) : Season.InProgressSeasonMatchGroup {
                {
                    time = mg.time;
                    state = #notScheduled();
                };
            },
        )
        |> Iter.toArray(_);
        seasonStatus := #inProgress({
            matchGroups = inProgressMatchGroups;
        });

        // Get first match group to open
        let #notScheduled(firstMatchGroup) = inProgressMatchGroups[0].state else Prelude.unreachable();

        await* scheduleMatchGroup(firstMatchGroup, stadiumId, prng);

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
        // TODO handle states where ledger exists but the team actor doesn't
        // Create canister for team ledger
        let ledger : LedgerActor = await createTeamLedger(request.tokenName, request.tokenSymbol);
        let ledgerId = Principal.fromActor(ledger);
        // Create canister for team logic
        let teamActor = await createTeamActor(ledgerId);
        let teamId = Principal.fromActor(teamActor);
        let team : Team.Team = {
            name = request.name;
            canister = teamActor;
            logoUrl = request.logoUrl;
            ledgerId = ledgerId;
        };
        let teamKey = buildPrincipalKey(teamId);
        let (newTeams, _) = Trie.put(teams, teamKey, Principal.equal, team);
        teams := newTeams;
        return #ok(teamId);
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
        let leagueId = Principal.fromActor(LeagueActor);
        let stadiumId = leagueId; // TODO
        for ((teamId, team) in Trie.iter(teams)) {
            let teamActor = actor (Principal.toText(teamId)) : Team.TeamActor;
            let ledgerId = team.ledgerId;

            let _ = await (system TeamActor.TeamActor)(#upgrade(teamActor))(
                leagueId,
                ledgerId,
            );
        };
        switch (stadiumIdOrNull) {
            case (null)();
            case (?id) {
                let stadiumActor = actor (Principal.toText(id)) : Stadium.StadiumActor;
                let _ = await (system StadiumActor.StadiumActor)(#upgrade(stadiumActor))(leagueId);
            };
        };
    };

    public shared ({ caller }) func onMatchGroupStart(request : Types.OnMatchGroupStartRequest) : async Types.OnMatchGroupStartResult {
        let #inProgress(season) = seasonStatus else return #matchGroupNotFound;
        let ?stadiumId = stadiumIdOrNull else return #notAuthorized;
        if (caller != stadiumId) {
            return #notAuthorized;
        };

        let key = {
            key = request.id;
            hash = request.id;
        };

        // Get current match group
        let ?matchGroupSchedule = Trie.get(
            season.matchGroups,
            key,
            Nat32.equal,
        ) else return #matchGroupNotFound;

        let matchGroupScheduledData = switch (matchGroupSchedule.status) {
            case (#notScheduled) return #notScheduledYet;
            case (#failedToSchedule(error)) return #notScheduledYet;
            case (#inProgress(_)) return #alreadyStarted;
            case (#completed(_)) return #alreadyStarted;
            case (#scheduled(d)) d;
        };

        let allPlayers = await PlayerLedgerActor.getTeamPlayers(null);
        let matchStartDataBuffer = Buffer.Buffer<Types.MatchStartOrSkip>(matchGroupSchedule.matches.size());

        let matches = matchGroupSchedule.matches
        |> Iter.fromArray(_)
        |> IterTools.zip(_, Iter.fromArray(matchGroupScheduledData.matches));

        for ((matchSchedule, state) in matches) {
            let data = await* buildMatchStartData(request.id, matchSchedule, state, allPlayers);
            matchStartDataBuffer.add(data);
        };
        let matchStartDataArray = Buffer.toArray(matchStartDataBuffer);

        let newStatus = #inProgress({
            stadiumId = stadiumId;
            matches = matchStartDataArray;
        });
        // Update status to inProgress
        setMatchGroupStatus(request.id, newStatus);

        let data : Types.MatchGroupStartData = {
            matches = matchStartDataArray;
        };

        #ok(data);
    };

    public shared ({ caller }) func onMatchGroupComplete(request : Types.OnMatchGroupCompleteRequest) : async Types.OnMatchGroupCompleteResult {
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
        let ?matchGroup = Util.arrayGetOpt<Season.InProgressSeasonMatchGroup>(
            season.matchGroups,
            request.id,
        ) else return #matchGroupNotFound;

        // Update status to completed
        let updatedMatchGroup = {
            matchGroup with
            state = #completed(request.state);
        };

        // Get next match group to schedule
        let nextMatchGroupId = request.id + 1;
        if (nextMatchGroupId >= season.matchGroups.size()) {
            // Season is over season.order
            let completedMatchGroups = buildCompletedMatchGroups(season);
            let teamStandings = calculateTeamStandings(completedMatchGroups);
            let completedTeams = Trie.toArray(
                teams,
                func(k : Principal, v : Team.Team) : Season.CompletedSeasonTeam {
                    let standingInfo = Trie.get(teamStandings, buildPrincipalKey(k), Principal.equal);
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
            return #ok;
        };

        // Schedule next match group
        await* scheduleMatchGroup({ matchGroupSchedule with id = nextMatchGroupId }, stadiumId, prng);
        #ok;
    };

    private func buildMatchStartData(
        matchGroupId : Nat32,
        team1Id : Principal,
        team2Id : Principal,
        matchAura : MatchAura.MatchAura,
        allPlayers : [Player.PlayerWithId],
    ) : async* Types.MatchStartOrSkipData {
        let team1InitOrNull = await* buildTeamInitData(matchGroupId, team1Id, allPlayers);
        let team2InitOrNull = await* buildTeamInitData(matchGroupId, team2Id, allPlayers);
        switch (team1InitOrNull, team2InitOrNull) {
            case (#ok(t1), #ok(t2)) {
                #start({
                    team1 = t1;
                    team2 = t2;
                    aura = matchAura;
                });
            };
            case (#ok(_), #noVotes) #absentTeam(#team2);
            case (#noVotes, #ok(_)) #absentTeam(#team1);
            case (#noVotes, #noVotes) #allAbsent;
        };
    };

    private func buildTeamInitData(
        matchGroupId : Nat32,
        teamId : Principal,
        allPlayers : [Player.PlayerWithId],
    ) : async* {
        #ok : Types.TeamStartData;
        #noVotes;
    } {
        let teamActor = actor (Principal.toText(teamId)) : Team.TeamActor;
        let options = try {
            // Get match options from the team itself
            let result : Team.GetMatchGroupVoteResult = await teamActor.getMatchGroupVote(matchGroupId);
            switch (result) {
                case (#noVotes) return #noVotes;
                case (#ok(o)) o;
                case (#notAuthorized) return Debug.trap("League is not authorized to get match options from team: " # Principal.toText(teamId));
            };
        } catch (err : Error.Error) {
            return Debug.trap("Failed to get team '" # Principal.toText(teamId) # "': " # Error.message(err));
        };
        let teamPlayers = allPlayers
        |> Iter.fromArray(_)
        |> Iter.filter(_, func(p : Player.PlayerWithId) : Bool = p.teamId == ?teamId)
        |> Iter.toArray(_);
        #ok({
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
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let stadium = try {
            await StadiumActor.StadiumActor(Principal.fromActor(LeagueActor));
        } catch (err) {
            return #stadiumCreationError(Error.message(err));
        };
        let stadiumId = Principal.fromActor(stadium);
        stadiumIdOrNull := ?stadiumId;
        #ok(stadiumId);
    };

    private func buildCompletedMatchGroups(
        season : Season.InProgressSeason
    ) : [Season.CompletedSeasonMatchGroupVariant] {
        season.matchGroups
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(matchGroupVariant : Season.InProgressSeasonMatchGroupVariant) : Season.CompletedSeasonMatchGroupVariant {
                switch (matchGroupVariant) {
                    case (#completed(completedMatchGroup)) #ok(completedMatchGroup);
                    case (#notScheduled(notScheduledMatchGroup)) #canceled({
                        time = notScheduledMatchGroup.time;
                        reason = "Match group was never scheduled";
                        matches = notScheduledMatchGroup.matches;
                    });
                    case (#scheduled(scheduledMatchGroup)) #canceled({
                        time = scheduledMatchGroup.time;
                        reason = "Match group was scheduled, but never started";
                        matches = scheduledMatchGroup.matches;
                    });
                    case (#failedToSchedule(errorMatchGroup)) #canceled({
                        time = errorMatchGroup.time;
                        reason = "Scheduling Error: " # debug_show (errorMatchGroup.error); // TODO debug_show?
                        matches = errorMatchGroup.matches;
                    });
                    case (#inProgress(inProgressMatchGroup)) #canceled({
                        time = inProgressMatchGroup.time;
                        reason = "Match group was started, but never completed";
                        matches = inProgressMatchGroup.matches
                        |> Iter.fromArray(_)
                        |> Iter.map(
                            _,
                            func(m : Season.InProgressMatchGroupMatchVariant) : Season.CanceledMatch {
                                switch (m) {
                                    case (#allAbsent(allAbsentMatch)) allAbsentMatch;
                                    case (#absentTeam(absentTeamMatch)) #absentTeam(#team1);
                                    case (#played(playedMatch)) #played({
                                        team1 = playedMatch.team1;
                                        team2 = playedMatch.team2;
                                        team1Score = playedMatch.team1Score;
                                        team2Score = playedMatch.team2Score;
                                        winner = playedMatch.winner;
                                    });
                                    case (#stateBroken(error)) #stateBroken(error);
                                };
                            },
                        )
                        |> Iter.toArray(_);
                    });
                };
            },
        )
        |> Iter.toArray(_);
    };

    type TeamSeasonStanding = { wins : Nat; losses : Nat; totalScore : Nat };

    private func calculateTeamStandings(
        matchGroups : [Season.CompletedMatchGroup]
    ) : Trie.Trie<Principal, TeamSeasonStanding> {
        var teamScores = Trie.empty<Principal, TeamSeasonStanding>();
        let updateTeamScore = func(
            teamId : Principal,
            score : Nat,
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
            let (newTeamScores, _) = Trie.put(
                teamScores,
                teamKey,
                Principal.equal,
                {
                    wins = if (won) currentScore.wins + 1 else currentScore.wins;
                    losses = if (won) currentScore.losses else currentScore.losses + 1;
                    totalScore = currentScore.totalScore + score;
                },
            );
            teamScores := newTeamScores;
        };

        // Populate scores
        label f1 for (matchGroup in Iter.fromArray(matchGroups)) {
            switch (matchGroup.state) {
                case (#canceled(_)) continue f1;
                case (#ok(state)) {
                    label f2 for (match in Iter.fromArray(state.matches)) {
                        switch (match.state) {
                            case (#allAbsent or #stateBroken(_)) {
                                updateTeamScore(match.team1, 0, false);
                                updateTeamScore(match.team2, 0, false);
                            };
                            case (#absentTeam(#team1)) {
                                updateTeamScore(match.team1, 0, false);
                                updateTeamScore(match.team2, 0, true);
                            };
                            case (#absentTeam(#team2)) {
                                updateTeamScore(match.team1, 0, true);
                                updateTeamScore(match.team2, 0, false);
                            };
                            case (#played(state)) {
                                updateTeamScore(match.team1, state.team1Score, itate.winner == #team1);
                                updateTeamScore(match.team2, state.team2Score, state.winner == #team2);
                            };
                        };
                    };
                };
            };
        };
        teamScores;
    };

    private func scheduleMatchGroup(
        matchGroup : Season.InProgressMatchGroup,
        stadiumId : Principal,
        prng : Prng,
    ) : async* () {

        let matchRequests = matchGroupState.matches
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(m : Season.InProgressSeasonMatchGroupInProgressStateMatch) : StadiumTypes.ScheduleMatchRequest {
                let offerings = getRandomOfferings(4);
                let aura = getRandomMatchAura(prng);
                {
                    team1Id = m.team1.id;
                    team2Id = m.team2.id;
                    offerings = offerings;
                    aura = aura;
                };
            },
        )
        |> Iter.toArray(_);
        let matchGroupRequest : StadiumTypes.ScheduleMatchGroupRequest = {
            id = matchGroupId;
            startTime = time;
            matches = matchRequests;
        };
        let stadiumActor = actor (Principal.toText(stadiumId)) : StadiumTypes.StadiumActor;
        let matchGroupStatus : Season.InProgressSeasonMatchGroupStateVariant = try {
            let stadiumResult = await stadiumActor.scheduleMatchGroup(matchGroupRequest);
            switch (stadiumResult) {
                case (#ok(scheduledMatchGroup)) {
                    let matches = matchGroupState.matches
                    |> Iter.fromArray(_)
                    |> IterTools.zip(_, Iter.fromArray(scheduledMatchGroup.matches))
                    |> Iter.map(
                        _,
                        func(m : (Season.InProgressSeasonMatchGroupInProgressStateMatch, StadiumTypes.Match)) : Types.ScheduledMatchState {
                            let offerings = m.1.offerings
                            |> Iter.fromArray(_)
                            |> Iter.map(_, func(o : Offering.OfferingWithMetaData) : Offering.Offering = o.offering)
                            |> Iter.toArray(_);
                            {
                                offerings = offerings;
                                matchAura = m.1.aura.aura;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                    #scheduled({ matches = matches });
                };
                case (#matchErrors(errors)) #failedToSchedule(#matchErrors(errors));
                case (#noMatchesSpecified) #failedToSchedule(#noMatchesSpecified);
                case (#playerFetchError(error)) #failedToSchedule(#playerFetchError(error));
                case (#teamFetchError(error)) #failedToSchedule(#teamFetchError(error));
            };
        } catch (err) {
            #failedToSchedule(#stadiumScheduleCallError(Error.message(err)));
        };
        setMatchGroupStatus(matchGroupSchedule.id, matchGroupStatus);
    };

    private func createTeamActor(ledgerId : Principal) : async TeamActor.TeamActor {
        let leagueId = Principal.fromActor(LeagueActor);
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 100_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        await TeamActor.TeamActor(
            leagueId,
            ledgerId,
        );
    };

    private func createTeamLedger(tokenName : Text, tokenSymbol : Text) : async LedgerActor {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);

        let leagueId = Principal.fromActor(LeagueActor);
        await Token.Token({
            name = tokenName;
            symbol = tokenSymbol;
            decimals = 0;
            fee = 0;
            max_supply = 1;
            initial_balances = [];
            min_burn_amount = 0;
            minting_account = ?{ owner = leagueId; subaccount = null };
            advanced_settings = null;
        });
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

    private func getRandomOfferings(count : Nat) : [Offering.Offering] {
        // TODO
        [
            #shuffleAndBoost
        ];
    };

    private func getRandomMatchAura(prng : Prng) : MatchAura.MatchAura {
        // TODO
        let auras = Buffer.fromArray<MatchAura.MatchAura>([
            #lowGravity,
            #explodingBalls,
            #fastBallsHardHits,
            #moreBlessingsAndCurses,
        ]);
        prng.shuffleBuffer(auras);
        auras.get(0);
    };

};
