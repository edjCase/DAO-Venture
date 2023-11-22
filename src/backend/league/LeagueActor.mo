import Team "../Team";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Cycles "mo:base/ExperimentalCycles";
import IterTools "mo:itertools/Iter";
import Hash "mo:base/Hash";
import Player "../Player";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Stadium "../Stadium";
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
import League "../League";
import Util "../Util";
import StadiumActor "../stadium/StadiumActor";
import ScheduleBuilder "ScheduleBuilder";
import PlayerLedgerActor "canister:playerLedger";

actor LeagueActor {
    type LedgerActor = Token.Token;
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type SeasonSchedule = {
        var matchGroups : Trie.Trie<Nat32, League.MatchGroupSchedule>;
        var order : [Nat32];
    };

    type SeasonStatus = {
        #notStarted;
        #starting;
        #inProgress : SeasonSchedule;
        #completed : League.CompletedSeasonSchedule;
    };

    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var seasonStatus : SeasonStatus = #notStarted;
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

    public query func getSeasonStatus() : async League.SeasonStatus {
        switch (seasonStatus) {
            case (#notStarted) #notStarted;
            case (#starting) #starting;
            case (#inProgress(season)) {
                let matchGroups = season.matchGroups
                |> Trie.iter(_)
                |> Iter.map(
                    _,
                    func(mg : (Nat32, League.MatchGroupSchedule)) : League.MatchGroupScheduleWithId = {
                        mg.1 with
                        id = mg.0;
                    },
                )
                |> Iter.toArray(_);
                #inProgress({
                    matchGroups = matchGroups;
                });
            };
            case (#completed(season)) #completed(season);
        };
    };

    public shared ({ caller }) func startSeason(request : League.StartSeasonRequest) : async League.StartSeasonResult {
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

        let schedule : League.SeasonSchedule = switch (buildResult) {
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
        let matchGroupSchedules = arrayToIdTrie(schedule.matchGroups, func(mg : League.MatchGroupScheduleWithId) : Nat32 = mg.id);
        let order = schedule.matchGroups
        |> Iter.fromArray(_)
        |> Iter.map(_, func(mg : League.MatchGroupScheduleWithId) : Nat32 = mg.id)
        |> Iter.toArray(_);
        seasonStatus := #inProgress({
            var matchGroups = matchGroupSchedules;
            var order = order;
        });

        // Get first match group to open
        let matchGroupSchedule = schedule.matchGroups[0];

        await* scheduleMatchGroup(matchGroupSchedule, stadiumId, prng);

        #ok;
    };

    public shared ({ caller }) func createTeam(request : League.CreateTeamRequest) : async League.CreateTeamResult {

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

    public shared ({ caller }) func mint(request : League.MintRequest) : async League.MintResult {
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

    public shared ({ caller }) func onMatchGroupStart(request : League.OnMatchGroupStartRequest) : async League.OnMatchGroupStartResult {
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
            case (#scheduleError(error)) return #notScheduledYet;
            case (#inProgress(_)) return #alreadyStarted;
            case (#completed(_)) return #alreadyStarted;
            case (#scheduled(d)) d;
        };

        let allPlayers = await PlayerLedgerActor.getTeamPlayers(null);
        let matchStartDataBuffer = Buffer.Buffer<League.MatchStartOrSkip>(matchGroupSchedule.matches.size());

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

        let data : League.MatchGroupStartData = {
            matches = matchStartDataArray;
        };

        #ok(data);
    };

    public shared ({ caller }) func onMatchGroupComplete(request : League.OnMatchGroupCompleteRequest) : async League.OnMatchGroupCompleteResult {
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

        // Update status to completed
        setMatchGroupStatus(request.id, #completed(request.state));

        // Get next match group to schedule
        let ?currentMatchGroupIndex = Array.indexOf(
            request.id,
            season.order,
            Nat32.equal,
        ) else Debug.trap("Cannot find order of match group with id: " # Nat32.toText(request.id));
        let nextMatchGroupIndex = currentMatchGroupIndex + 1;
        if (nextMatchGroupIndex >= season.order.size()) {
            // Season is over season.order
            let completedMatchGroups = buildCompletedMatchGroups(season);
            let completedTeams = Trie.toArray(
                teams,
                func(k : Principal, v : Team.Team) : League.CompletedSeasonTeam = {
                    id = k;
                    name = v.name;
                    logoUrl = v.logoUrl;
                    ledgerId = v.ledgerId;
                },
            );
            let teamStandings = calculateTeamStandings(completedMatchGroups);
            seasonStatus := #completed({
                teamStandings = teamStandings;
                teams = completedTeams;
                matchGroups = completedMatchGroups;
            });
            return #ok;
        };
        let nextMatchGroupId = season.order[nextMatchGroupIndex];

        // Schedule next match group
        await* scheduleMatchGroup({ matchGroupSchedule with id = nextMatchGroupId }, stadiumId, prng);
        #ok;
    };

    private func buildMatchStartData(
        matchGroupId : Nat32,
        match : League.MatchSchedule,
        state : League.ScheduledMatchState,
        allPlayers : [Player.PlayerWithId],
    ) : async* League.MatchStartOrSkip {
        let team1InitOrNull = await* buildTeamInitData(matchGroupId, match.team1Id, allPlayers);
        let team2InitOrNull = await* buildTeamInitData(matchGroupId, match.team2Id, allPlayers);
        switch (team1InitOrNull, team2InitOrNull) {
            case (#ok(t1), #ok(t2)) {
                #start({
                    team1 = t1;
                    team2 = t2;
                    aura = state.matchAura;
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
        #ok : League.TeamStartData;
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
        season : SeasonSchedule
    ) : [League.CompletedMatchGroup] {
        season.order
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(id : Nat32) : League.CompletedMatchGroup {
                let ?matchGroupSchedule = Trie.get(
                    season.matchGroups,
                    {
                        key = id;
                        hash = id;
                    },
                    Nat32.equal,
                ) else Debug.trap("Cannot find match group with id: " # Nat32.toText(id));
                let completedState : League.CompletedMatchGroupState = switch (matchGroupSchedule.status) {
                    case (#notScheduled) #unplayed(#notStarted);
                    case (#scheduled(state)) #unplayed(#notStarted); // TODO notStarted?
                    case (#completed(state)) state;
                    case (#inProgress(state)) #unplayed(#inProgress);
                    case (#scheduleError(error)) #unplayed(#scheduleError(error));
                };

                {
                    id = id;
                    state = completedState;
                };
            },
        )
        |> Iter.toArray(_);
    };

    private func calculateTeamStandings(matchGroups : [League.CompletedMatchGroup]) : [Principal] {
        var teamScores = Trie.empty<Principal, Nat>();
        let updateTeamScore = func(
            teamId : Principal,
            score : { #set : Nat; #add : Nat },
        ) : () {

            let teamKey = {
                key = teamId;
                hash = Principal.hash(teamId);
            };
            let teamScore : Nat = switch (score) {
                case (#set(value)) value;
                case (#add(value)) {
                    switch (Trie.get(teamScores, teamKey, Principal.equal)) {
                        case (null) value; // Set if no entries for team yet
                        case (?score) score + value;
                    };
                };
            };
            // Update with +1
            let (newTeamScores, _) = Trie.put(
                teamScores,
                teamKey,
                Principal.equal,
                teamScore,
            );
            teamScores := newTeamScores;
        };

        // Initialize team scores with 0
        for ((teamId, team) in Trie.iter(teams)) {
            updateTeamScore(teamId, #set(0));
        };
        // Populate scores
        label f1 for (matchGroup in Iter.fromArray(matchGroups)) {
            switch (matchGroup.state) {
                case (#unplayed(_)) continue f1;
                case (#played(matches)) {
                    label f2 for (match in Iter.fromArray(matches)) {
                        let winningTeamIdOrTie : ?Principal = switch (match.state) {
                            case (#allAbsent) continue f2;
                            case (#absentTeam(#team1)) ?match.team2.id;
                            case (#absentTeam(#team2)) ?match.team1.id;
                            case (#stateBroken(error)) continue f2;
                            case (#played(state)) {
                                switch (state.winner) {
                                    case (#team1) ?match.team1.id;
                                    case (#team2) ?match.team2.id;
                                    case (#tie) null;
                                };
                            };
                        };
                        switch (winningTeamIdOrTie) {
                            case (null) {
                                // Tie, both teams get a point
                                updateTeamScore(match.team1.id, #add(1));
                                updateTeamScore(match.team2.id, #add(1));
                            };
                            case (?winningTeamId) {
                                updateTeamScore(winningTeamId, #add(1));
                            };
                        };
                    };
                };
            };
        };
        teamScores
        |> Trie.iter(_)
        // Sort by highest score first
        // TODO other sorting criteria for tie breakers
        |> Iter.sort(
            _,
            func(
                a : (Principal, Nat),
                b : (Principal, Nat),
            ) : Order.Order = Nat.compare(a.1, b.1),
        )
        // Get team ids
        |> Iter.map(_, func(t : (Principal, Nat)) : Principal = t.0)
        |> Iter.toArray(_);
    };

    private func scheduleMatchGroup(
        matchGroupSchedule : League.MatchGroupScheduleWithId,
        stadiumId : Principal,
        prng : Prng,
    ) : async* () {

        let matchRequests : [Stadium.ScheduleMatchRequest] = matchGroupSchedule.matches
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(m : League.MatchSchedule) : Stadium.ScheduleMatchRequest {
                let offerings = getRandomOfferings(4);
                let aura = getRandomMatchAura(prng);
                {
                    team1Id = m.team1Id;
                    team2Id = m.team2Id;
                    offerings = offerings;
                    aura = aura;
                };
            },
        )
        |> Iter.toArray(_);
        let matchGroupRequest : Stadium.ScheduleMatchGroupRequest = {
            id = matchGroupSchedule.id;
            startTime = matchGroupSchedule.time;
            matches = matchRequests;
        };
        let stadiumActor = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
        let matchGroupStatus : League.MatchGroupScheduleStatus = try {
            let stadiumResult = await stadiumActor.scheduleMatchGroup(matchGroupRequest);
            switch (stadiumResult) {
                case (#ok(scheduledMatchGroup)) {
                    let matches = matchGroupSchedule.matches
                    |> Iter.fromArray(_)
                    |> IterTools.zip(_, Iter.fromArray(scheduledMatchGroup.matches))
                    |> Iter.map(
                        _,
                        func(m : (League.MatchSchedule, Stadium.Match)) : League.ScheduledMatchState {
                            let offerings = m.1.offerings
                            |> Iter.fromArray(_)
                            |> Iter.map(_, func(o : Stadium.OfferingWithMetaData) : Stadium.Offering = o.offering)
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
                case (#matchErrors(errors)) #scheduleError(#matchErrors(errors));
                case (#noMatchesSpecified) #scheduleError(#noMatchesSpecified);
                case (#playerFetchError(error)) #scheduleError(#playerFetchError(error));
                case (#teamFetchError(error)) #scheduleError(#teamFetchError(error));
            };
        } catch (err) {
            #scheduleError(#stadiumScheduleCallError(Error.message(err)));
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

    private func setMatchGroupStatus(
        matchGroupId : Nat32,
        newStatus : League.MatchGroupScheduleStatus,
    ) : () {
        let #inProgress(season) = seasonStatus else Debug.trap("Cannot open match group when season is not open");

        let key = {
            key = matchGroupId;
            hash = matchGroupId;
        };

        // Get current match group
        let ?matchGroupSchedule : ?League.MatchGroupSchedule = Trie.get(
            season.matchGroups,
            key,
            Nat32.equal,
        ) else Debug.trap("Cannot find match group with id: " # Nat32.toText(matchGroupId));

        let newMatchGroupSchedule : League.MatchGroupSchedule = {
            matchGroupSchedule with
            status = newStatus;
        };

        // TODO should the stadium generate the ids?
        let (newMatchGroupSchedules, _) = Trie.put(
            season.matchGroups,
            key,
            Nat32.equal,
            newMatchGroupSchedule,
        );
        season.matchGroups := newMatchGroupSchedules;
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

    private func buildRequestFromMatchGroupSchedule(
        mg : League.MatchGroupScheduleWithId,
        prng : Prng,
    ) : Stadium.ScheduleMatchGroupRequest {
        let offerings = getRandomOfferings(4);
        let aura = getRandomMatchAura(prng);
        let matches = mg.matches
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(m : League.MatchSchedule) : Stadium.ScheduleMatchRequest {
                {
                    team1Id = m.team1Id;
                    team2Id = m.team2Id;
                    offerings = offerings;
                    aura = aura;
                };
            },
        )
        |> Iter.toArray(_);
        {
            id = mg.id;
            startTime = mg.time;
            matches = matches;
        };
    };

    private func getRandomOfferings(count : Nat) : [Stadium.Offering] {
        // TODO
        [
            #shuffleAndBoost
        ];
    };

    private func getRandomMatchAura(prng : Prng) : Stadium.MatchAura {
        // TODO
        let auras = Buffer.fromArray<Stadium.MatchAura>([
            #lowGravity,
            #explodingBalls,
            #fastBallsHardHits,
            #moreBlessingsAndCurses,
        ]);
        prng.shuffleBuffer(auras);
        auras.get(0);
    };

};
