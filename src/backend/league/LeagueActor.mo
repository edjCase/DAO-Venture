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
    type Division = League.Division;
    type DivisionWithId = League.DivisionWithId;
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;
    type SeasonStatus = {
        #closed;
        #starting;
        #open : {
            var matchGroups : Trie.Trie<Nat32, League.MatchGroupSchedule>;
            var divisions : Trie.Trie<Nat32, League.DivisionSchedule>;
        };
    };

    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var divisions : Trie.Trie<Nat32, Division> = Trie.empty();
    stable var seasonStatus : SeasonStatus = #closed;
    stable var stadiumIdOrNull : ?Principal = null;

    public query func getDivisions() : async [DivisionWithId] {
        Trie.toArray(
            divisions,
            func(k : Nat32, v : Division) : DivisionWithId = {
                v with
                id = k;
            },
        );
    };

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
                divisionId = v.divisionId;
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

        let divisions = season.divisions
        |> Trie.iter(_)
        // Add id
        |> Iter.map(
            _,
            func(d : (Nat32, League.DivisionSchedule)) : League.DivisionScheduleWithId = {
                d.1 with
                id = d.0;
            },
        )
        // Order by id
        |> IterTools.sort(
            _,
            func(
                a : League.DivisionScheduleWithId,
                b : League.DivisionScheduleWithId,
            ) : Order.Order = Nat32.compare(a.id, b.id),
        )
        |> Iter.toArray(_);
        ?{
            matchGroups = matchGroups;
            divisions = divisions;
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

    public shared ({ caller }) func createDivision(request : League.CreateDivisionRequest) : async League.CreateDivisionResult {
        let leagueId = Principal.fromActor(LeagueActor);
        // TODO
        // if (caller != leagueId) {
        //   return #notAuthorized;
        // }

        let nameAlreadyTaken = Trie.some(
            divisions,
            func(k : Nat32, v : Division) : Bool = v.name == request.name,
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };
        let stadiumId = switch (stadiumIdOrNull) {
            case (null) return #noStadiumsExist;
            case (?id) id;
        };
        let divisionId = Nat32.fromNat(Trie.size(divisions) + 1);
        let division : Division = {
            name = request.name;
        };
        let divisionKey = {
            key = divisionId;
            hash = divisionId;
        };
        let (newDivisions, _) = Trie.put(divisions, divisionKey, Nat32.equal, division);
        divisions := newDivisions;
        return #ok(divisionId);
    };

    public shared ({ caller }) func startSeason(request : League.StartSeasonRequest) : async League.StartSeasonResult {
        let #closed = seasonStatus else return #alreadyStarted;
        seasonStatus := #starting;

        let ?stadiumId = stadiumIdOrNull else return #noStadiumsExist;
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromSeed(Blob.hash(seedBlob));

        let divisionsArray = Trie.toArray(
            divisions,
            func(k : Nat32, v : Division) : DivisionWithId = {
                v with
                id = k;
            },
        );
        let teamsArray = Trie.toArray(
            teams,
            func(k : Principal, v : Team.Team) : TeamWithId = {
                id = k;
                name = v.name;
                logoUrl = v.logoUrl;
                ledgerId = v.ledgerId;
                divisionId = v.divisionId;
            },
        );
        let buildResult = ScheduleBuilder.build(request, divisionsArray, teamsArray, prng);

        let schedule : League.SeasonSchedule = switch (buildResult) {
            case (#ok(schedule)) schedule;
            case (#error(errors)) return #divisionErrors(errors);
        };

        // Save full schedule, then try to start the first match groups

        // Get first match group from each division to open
        let firstMatchGroups : [League.MatchGroupSchedule] = schedule.divisions
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(d : League.DivisionSchedule) : League.MatchGroupSchedule {
                let idMatchesFunc = func(mg : League.MatchGroupSchedule) : Bool = mg.id == d.matchGroupIds[0];
                let ?firstMatchGroup = Array.find(schedule.matchGroups, idMatchesFunc) else Debug.trap("Cannot find match group with id: " # Nat32.toText(d.matchGroupIds[0]));
                firstMatchGroup;
            },
        )
        |> Iter.toArray(_);

        let matchGroupRequests = firstMatchGroups
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(mg : League.MatchGroupSchedule) : Stadium.ScheduleMatchGroupRequest = buildRequestFromMatchGroupSchedule(mg, prng),
        )
        |> Iter.toArray(_);
        let stadiumRequest : Stadium.ScheduleMatchGroupsRequest = {
            matchGroups = matchGroupRequests;
        };
        let stadiumActor = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
        try {
            let stadiumResult = await stadiumActor.scheduleMatchGroups(stadiumRequest);
            switch (stadiumResult) {
                case (#ok(openedMatchGroups)) {
                    var matchGroupSchedules = arrayToIdTrie(schedule.matchGroups, func(mg : League.MatchGroupScheduleWithId) : Nat32 = mg.id);
                    var divisionSchedules = arrayToIdTrie(schedule.divisions, func(d : League.DivisionScheduleWithId) : Nat32 = d.id);
                    seasonStatus := #open({
                        var matchGroups = matchGroupSchedules;
                        var divisions = divisionSchedules;
                    });
                    for (openedMatchGroup in Iter.fromArray(openedMatchGroups)) {
                        openMatchGroupStatus(openedMatchGroup);
                    };
                    #ok;
                };
                case (#matchGroupErrors(errors)) #stadiumScheduleError(#matchGroupErrors(errors));
                case (#noMatchGroupSpecified) #stadiumScheduleError(#noMatchGroupSpecified);
                case (#playerFetchError(error)) #stadiumScheduleError(#playerFetchError(error));
                case (#teamFetchError(error)) #stadiumScheduleError(#teamFetchError(error));
            };
        } catch (err) {
            #stadiumScheduleError(#unknown(Error.message(err)));
        };
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
        let divisionExists = Trie.some(
            divisions,
            func(k : Nat32, v : Division) : Bool = k == request.divisionId,
        );
        if (not divisionExists) {
            return #divisionNotFound;
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
            divisionId = request.divisionId;
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

    private func openMatchGroupStatus(matchGroup : Stadium.MatchGroupWithId) : () {
        let #open(season) = seasonStatus else Debug.trap("Cannot open match group when season is not open");

        let key = {
            key = matchGroup.id;
            hash = matchGroup.id;
        };

        // Get current match group
        let ?matchGroupSchedule = Trie.get(season.matchGroups, key, Nat32.equal) else Debug.trap("Cannot find match group with id: " # Nat32.toText(matchGroup.id));

        let matches = matchGroupSchedule.matches
        |> Iter.fromArray(_)
        |> IterTools.zip(_, Iter.fromArray(matchGroup.matches))
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

        let newMatchGroupSchedule : League.MatchGroupSchedule = {
            matchGroupSchedule with
            status = #open({
                matches = matches;
            });
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
        mg : League.MatchGroupSchedule,
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
