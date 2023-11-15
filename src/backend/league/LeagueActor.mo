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

actor LeagueActor {
    type LedgerActor = Token.Token;
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type SeasonSchedule = {
        var matchGroups : Trie.Trie<Nat32, League.MatchGroupSchedule>;
        var order : [Nat32];
    };

    type SeasonStatus = {
        #closed;
        #starting;
        #open : SeasonSchedule;
    };

    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var seasonStatus : SeasonStatus = #closed;
    stable var stadiumIdOrNull : ?Principal = null;

    public shared query ({ caller }) func getStadiums() : async [Stadium.StadiumWithId] {
        return switch (stadiumIdOrNull) {
            case (null)[];
            case (?id) { [{ id = id }] };
        };
    };

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

    public composite query func getSeasonSchedule() : async ?League.SeasonSchedule {
        let #open(season) = seasonStatus else return null;
        let matchGroups = season.matchGroups
        |> Trie.iter(_)
        // Add id
        |> Iter.map(
            _,
            func(mg : (Nat32, League.MatchGroupSchedule)) : League.MatchGroupScheduleWithId = {
                mg.1 with
                id = mg.0;
            },
        )
        // Order by start time
        |> IterTools.sort(
            _,
            func(
                a : League.MatchGroupScheduleWithId,
                b : League.MatchGroupScheduleWithId,
            ) : Order.Order = Int.compare(a.time, b.time),
        )
        |> Iter.toArray(_);

        ?{
            matchGroups = matchGroups;
        };
    };

    public shared ({ caller }) func createStadium() : async League.CreateStadiumResult {
        switch (stadiumIdOrNull) {
            case (null)();
            case (?id) return #alreadyCreated;
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

    public shared ({ caller }) func startSeason(request : League.StartSeasonRequest) : async League.StartSeasonResult {
        let #closed = seasonStatus else return #alreadyStarted;
        let ?stadiumId = stadiumIdOrNull else return #noStadiumsExist;
        seasonStatus := #starting;

        let seedBlob = try {
            await Random.blob();
        } catch (err) {
            seasonStatus := #closed;
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
                seasonStatus := #closed;
                return #noTeams;
            };
            case (#oddNumberOfTeams) {
                seasonStatus := #closed;
                return #oddNumberOfTeams;
            };
        };

        // Save full schedule, then try to start the first match groups
        let matchGroupSchedules = arrayToIdTrie(schedule.matchGroups, func(mg : League.MatchGroupScheduleWithId) : Nat32 = mg.id);
        let order = schedule.matchGroups
        |> Iter.fromArray(_)
        |> Iter.map(_, func(mg : League.MatchGroupScheduleWithId) : Nat32 = mg.id)
        |> Iter.toArray(_);
        seasonStatus := #open({
            var matchGroups = matchGroupSchedules;
            var order = order;
        });

        // Get first match group to open
        let matchGroupSchedule = schedule.matchGroups[0];

        await* scheduleMatchGroup(matchGroupSchedule, stadiumId, prng);

        #ok;
    };

    public shared ({ caller }) func createTeam(request : League.CreateTeamRequest) : async League.CreateTeamResult {

        let ?stadiumId = stadiumIdOrNull else return #noStadiumsExist;
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
        let teamActor = await createTeamActor(ledgerId, stadiumId);
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
                stadiumId,
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

    public shared ({ caller }) func onMatchGroupComplete(request : League.OnMatchGroupCompleteRequest) : async League.OnMatchGroupCompleteResult {
        let #open(season) = seasonStatus else return #seasonNotOpen;
        let ?stadiumId = stadiumIdOrNull else Debug.trap("No stadium exists"); // TODO?
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

        let newMatchGroupSchedule : League.MatchGroupSchedule = {
            matchGroupSchedule with
            // Update state
            state = #completed(request.state);
        };

        let (newMatchGroupSchedules, _) = Trie.put(
            season.matchGroups,
            key,
            Nat32.equal,
            newMatchGroupSchedule,
        );
        season.matchGroups := newMatchGroupSchedules;

        // Get next match group to schedule
        let ?currentMatchGroupIndex = Array.indexOf(
            request.id,
            season.order,
            Nat32.equal,
        ) else Debug.trap("Cannot find order of match group with id: " # Nat32.toText(request.id));
        let nextMatchGroupIndex = currentMatchGroupIndex + 1;
        if (nextMatchGroupIndex >= season.order.size()) {
            // Season is over
            seasonStatus := #closed;
            return #ok;
        };
        let nextMatchGroupId = season.order[nextMatchGroupIndex];

        // Schedule next match group
        await* scheduleMatchGroup({ matchGroupSchedule with id = nextMatchGroupId }, stadiumId, prng);
        #ok;
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
                case (#ok(openedMatchGroup)) {
                    let matches = matchGroupSchedule.matches
                    |> Iter.fromArray(_)
                    |> IterTools.zip(_, Iter.fromArray(openedMatchGroup.matches))
                    |> Iter.map(
                        _,
                        func(m : (League.MatchSchedule, Stadium.Match)) : League.OpenMatchScheduleStatus {
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
                    #open({ matches = matches });
                };
                case (#matchErrors(errors)) #error(#matchErrors(errors));
                case (#noMatchesSpecified) #error(#noMatchesSpecified);
                case (#playerFetchError(error)) #error(#playerFetchError(error));
                case (#teamFetchError(error)) #error(#teamFetchError(error));
            };
        } catch (err) {
            #error(#scheduleError(Error.message(err)));
        };
        setMatchGroupStatus(matchGroupSchedule.id, matchGroupStatus);
    };

    private func createTeamActor(ledgerId : Principal, stadiumId : Principal) : async TeamActor.TeamActor {
        let leagueId = Principal.fromActor(LeagueActor);
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 100_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        await TeamActor.TeamActor(
            leagueId,
            stadiumId,
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
        let #open(season) = seasonStatus else Debug.trap("Cannot open match group when season is not open");

        let key = {
            key = matchGroupId;
            hash = matchGroupId;
        };

        // Get current match group
        let ?matchGroupSchedule = Trie.get(
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
