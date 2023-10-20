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
import Token "mo:icrc1/ICRC1/Canisters/Token";
import ICRC1 "mo:icrc1/ICRC1";

actor LeagueActor {

    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
    };
    public type CreateStadiumResult = {
        #ok : Principal;
    };
    public type ScheduleMatchResult = Stadium.ScheduleMatchResult or {
        #stadiumNotFound;
    };
    public type TeamInfo = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        ledgerId : Principal; // TODO this is duplicated in TeamActor
    };
    public type StadiumInfo = {
        id : Principal;
        name : Text;
    };
    public type CreateTeamDaoResult = {
        #ok : Principal;
        #notAuthenticated;
        #error : Text;
    };

    type LedgerActor = Token.Token;

    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var stadiums : Trie.Trie<Principal, Stadium.Stadium> = Trie.empty();
    stable var nextPlayerId : Nat = 0;

    public type TeamInitializationConfig = {
        name : Text;
    };

    public query func getTeams() : async [TeamInfo] {
        Trie.toArray(
            teams,
            func(k : Principal, v : Team.Team) : TeamInfo = {
                id = k;
                name = v.name;
                logoUrl = v.logoUrl;
                ledgerId = v.ledgerId;
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

    public shared ({ caller }) func createTeam(
        name : Text,
        logoUrl : Text,
        tokenName : Text,
        tokenSymbol : Text,
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
        };
        let teamKey = buildKey(teamId);
        switch (Trie.put(teams, teamKey, Principal.equal, team)) {
            case (_, ?previous) Prelude.unreachable(); // No way new id can conflict with existing one
            case (newTeams, null) {
                teams := newTeams;
                return #ok(teamId);
            };
        };
    };

    public shared ({ caller }) func mint(
        amount : Nat,
        teamId : Principal,
        to : Principal,
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
                owner = to;
                subaccount = null;
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
