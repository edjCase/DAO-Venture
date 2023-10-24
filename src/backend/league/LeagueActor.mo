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
import StadiumCanister "../stadium/StadiumActor";
import { ic } "mo:ic";
import Time "mo:base/Time";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Token "mo:icrc1/ICRC1/Canisters/Token";
import ICRC1 "mo:icrc1/ICRC1";
import TimeZone "mo:datetime/TimeZone";
import LocalDateTime "mo:datetime/LocalDateTime";
import Components "mo:datetime/Components";
import DateTime "mo:datetime/DateTime";
import RandomX "mo:random/RandomX";
import League "../League";

actor LeagueActor {
    type MatchUp = League.MatchUp;
    type Week = League.Week;
    type ScheduleMatchResult = League.ScheduleMatchResult;
    type CreateStadiumResult = League.CreateStadiumResult;
    type CreateTeamResult = League.CreateTeamResult;
    type TimeOfDay = League.TimeOfDay;
    type DayOfWeek = League.DayOfWeek;
    type StadiumInfo = League.StadiumInfo;
    type TeamInfo = League.TeamInfo;
    type Division = League.Division;
    type LedgerActor = Token.Token;

    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var stadiums : Trie.Trie<Principal, Stadium.Stadium> = Trie.empty();
    stable var divisions : Trie.Trie<Nat32, Division> = Trie.empty();

    public query func getTeams() : async [TeamInfo] {
        Trie.toArray(
            teams,
            func(k : Principal, v : Team.Team) : TeamInfo = {
                id = k;
                name = v.name;
                logoUrl = v.logoUrl;
                ledgerId = v.ledgerId;
                divisionId = v.divisionId;
            },
        );
    };
    public query func getStadiums() : async [StadiumInfo] {
        Trie.toArray(
            stadiums,
            func(k : Principal, v : Stadium.Stadium) : StadiumInfo = {
                id = k;
                name = v.name;
            },
        );
    };

    public shared ({ caller }) func createDivision(
        name : Text,
        dayOfWeek : DayOfWeek,
        timeZone : TimeZone.FixedTimeZone,
        timeOfDay : TimeOfDay,
    ) : async {
        #ok;
    } {
        let leagueId = Principal.fromActor(LeagueActor);
        // TODO
        // if (caller != leagueId) {
        //   return #notAuthorized;
        // }
        let divisionId : Nat32 = Nat32.fromNat(Trie.size(divisions));
        let division : Division = {
            name = name;
            dayOfWeek = dayOfWeek;
            timeZone = timeZone;
            timeOfDay = timeOfDay;
            schedule = null;
        };
        let divisionKey = { key = divisionId; hash = divisionId };
        let (newDivisions, _) = Trie.put(divisions, divisionKey, Nat32.equal, division);
        divisions := newDivisions;
        return #ok;
    };

    public shared ({ caller }) func setSchedule() : async {
        #ok;
        #oddNumberOfTeams;
        #notEnoughStadiums;
    } {
        let random = RandomX.FiniteX(await Random.blob());
        for ((divisionId, division) in Trie.iter(divisions)) {
            let schedule = switch (await* generateSchedule(divisionId, division, random)) {
                case (#ok(schedule)) schedule;
                case (#oddNumberOfTeams) return #oddNumberOfTeams;
                case (#notEnoughStadiums) return #notEnoughStadiums;
            };

            let divisionKey = { key = divisionId; hash = divisionId };
            let (newDivisions, _) = Trie.put<Nat32, Division>(
                divisions,
                divisionKey,
                Nat32.equal,
                {
                    division with
                    schedule = ?schedule;
                },
            );
            divisions := newDivisions;
        };
        #ok;
    };

    private func generateSchedule(
        divisionId : Nat32,
        division : Division,
        random : RandomX.FiniteX,
    ) : async* { #ok : [Week]; #oddNumberOfTeams; #notEnoughStadiums } {
        let teamCount = Trie.size(teams);
        if (teamCount % 2 == 1) {
            return #oddNumberOfTeams;
        };
        let matchUpsPerWeek = teamCount / 2;
        if (matchUpsPerWeek > Trie.size(stadiums)) {
            return #notEnoughStadiums;
        };
        let ?randomizedTeams = Trie.iter(teams)
        |> Iter.filter<(Principal, Team.Team)>(
            _,
            func(v) = v.1.divisionId == divisionId,
        )
        |> Iter.toArray(_)
        |> random.shuffleElements(_) else Debug.trap("Not enough entropy");

        let teamPairings = Buffer.Buffer<(Principal, Principal)>(teamCount * (teamCount - 1));
        for (i in IterTools.range(0, teamCount - 2)) {
            for (j in IterTools.range(i, teamCount - 1)) {
                teamPairings.add((randomizedTeams.get(i).0, randomizedTeams.get(j).0));
            };
        };
        let weekCount = if (teamPairings.size() % matchUpsPerWeek != 0) {
            teamPairings.size() / matchUpsPerWeek + 1; // Round up weeks
        } else {
            teamPairings.size() / matchUpsPerWeek;
        };
        let today = LocalDateTime.now(#fixed(division.timeZone)).toComponents();
        let nextMatchComponents = if (Components.dayOfWeek(today) == division.dayOfWeek) {
            // If on the same day, put it a week out
            Components.add(today, #days(7));
        } else {
            Components.advanceToDayOfWeek(today, division.dayOfWeek);
        };
        var nextMatchDate = LocalDateTime.LocalDateTime(
            {
                nextMatchComponents with
                hour = division.timeOfDay.hour;
                minute = division.timeOfDay.minute;
                nanosecond = 0;
            },
            #fixed(division.timeZone),
        );

        let weeks = Buffer.Buffer<Week>(weekCount);
        for (weekId in IterTools.range(0, weekCount)) {
            let matchUps = Buffer.Buffer<MatchUp>(matchUpsPerWeek);

            let ?randomizedStadiums = Trie.iter(stadiums)
            |> Iter.toArray(_)
            |> random.shuffleElements(_) else Debug.trap("Not enough entropy");
            for (i in IterTools.range(0, matchUpsPerWeek)) {
                let stadiumId = randomizedStadiums.get(i).0;
                let teams = teamPairings.get(weekId * i);
                let status = try {
                    let stadium = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
                    let scheduleResult = await stadium.scheduleMatch(teams, nextMatchDate.toTime());
                    switch (scheduleResult) {
                        case (#ok(id)) #scheduled(id);
                        case (#duplicateTeams) #failedToSchedule(#duplicateTeams);
                        case (#timeNotAvailable) #failedToSchedule(#timeNotAvailable);
                    };
                } catch (err) {
                    #failedToSchedule(#unknown(Error.message(err)));
                };
                matchUps.add({
                    status = status;
                    stadiumId = stadiumId;
                    team1 = teams.0;
                    team2 = teams.1;
                });
            };
            weeks.add({
                matchUps = Buffer.toArray(matchUps);
            });
            nextMatchDate := nextMatchDate.add(#weeks(1));
        };
        #ok(Buffer.toArray(weeks));
    };

    public shared ({ caller }) func createTeam(
        name : Text,
        logoUrl : Text,
        tokenName : Text,
        tokenSymbol : Text,
        divisionId : Nat32,
    ) : async CreateTeamResult {

        let nameAlreadyTaken = Trie.some(
            teams,
            func(k : Principal, v : Team.Team) : Bool {
                v.name == name;
            },
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };
        let divisionKey = { key = divisionId; hash = divisionId };
        if (Trie.get(divisions, divisionKey, Nat32.equal) == null) {
            return #divisionNotFound;
        };
        let leagueId = Principal.fromActor(LeagueActor);
        // Create canister for team ledger
        let ledger : LedgerActor = await createTeamLedger(tokenName, tokenSymbol);
        let ledgerId = Principal.fromActor(ledger);
        // Create canister for team logic
        let teamActor = await createTeamActor(ledgerId);
        let teamId = Principal.fromActor(teamActor);
        let team : Team.Team = {
            name = name;
            canister = teamActor;
            logoUrl = logoUrl;
            ledgerId = ledgerId;
            divisionId = divisionId;
        };
        let teamKey = buildKey(teamId);
        let (newTeams, _) = Trie.put(teams, teamKey, Principal.equal, team);
        teams := newTeams;
        return #ok(teamId);
    };

    public shared ({ caller }) func mint(
        amount : Nat,
        teamId : Principal,
    ) : async {
        #ok : ICRC1.TxIndex;
        #teamNotFound;
        #transferError : ICRC1.TransferError;
    } {
        let leagueId = Principal.fromActor(LeagueActor);
        // TODO
        // if (caller != leagueId) {
        //   return #notAuthorized;
        // }
        let ?team = Trie.get(teams, buildKey(teamId), Principal.equal) else return #teamNotFound;
        let ledger = actor (Principal.toText(team.ledgerId)) : Token.Token;

        let transferResult = await ledger.mint({
            amount = amount;
            created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
            memo = null;
            to = {
                owner = teamId;
                subaccount = ?Principal.toBlob(caller);
            };
        });
        switch (transferResult) {
            case (#Ok(txIndex)) #ok(txIndex);
            case (#Err(error)) #transferError(error);
        };
    };

    public shared ({ caller }) func createStadium(name : Text) : async CreateStadiumResult {
        // TODO validate name

        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 3_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let stadiumCanister = await StadiumCanister.StadiumActor(Principal.fromActor(LeagueActor));
        let stadium : Stadium.Stadium = {
            name = name;
            canister = stadiumCanister;
        };

        let stadiumId = Principal.fromActor(stadiumCanister);
        let stadiumKey = buildKey(stadiumId);
        switch (Trie.put(stadiums, stadiumKey, Principal.equal, stadium)) {
            case (_, ?previous) Prelude.unreachable(); // No way new id can conflict with existing one
            case (newStadiums, null) {
                stadiums := newStadiums;
                return #ok(stadiumId);
            };
        };
    };

    public shared ({ caller }) func scheduleMatch(
        stadiumId : Principal,
        teamIds : (Principal, Principal),
        time : Time.Time,
    ) : async ScheduleMatchResult {
        let ?stadium = Trie.get(stadiums, buildKey(stadiumId), Principal.equal) else return #stadiumNotFound;
        await stadium.canister.scheduleMatch(teamIds, time);
    };

    public shared ({ caller }) func updateLeagueCanisters() : async () {
        let leagueId = Principal.fromActor(LeagueActor);
        for ((teamId, team) in Trie.iter(teams)) {
            let ownerId = caller; // TODO - get owner from team
            let _ = await (system TeamActor.TeamActor)(#upgrade(team.canister))(leagueId, ownerId);
        };
        for ((stadiumId, stadium) in Trie.iter(stadiums)) {
            let _ = await (system StadiumCanister.StadiumActor)(#upgrade(stadium.canister))(leagueId);
        };
    };

    private func createTeamActor(ledgerId : Principal) : async TeamActor.TeamActor {
        let leagueId = Principal.fromActor(LeagueActor);
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 3_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        await TeamActor.TeamActor(
            leagueId,
            ledgerId,
        );
    };

    private func createTeamLedger(tokenName : Text, tokenSymbol : Text) : async LedgerActor {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 3_000_000_000_000;
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

    private func buildKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };
};
