import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Token "mo:icrc1/ICRC1/Canisters/Token";
import Division "../Division";
import Team "../Team";
import League "../League";
import TeamActor "../team/TeamActor";
import Cycles "mo:base/ExperimentalCycles";
import Hash "mo:base/Hash";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Random "mo:base/Random";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import Array "mo:base/Array";
import PseudoRandomX "mo:random/PseudoRandomX";
import DateTime "mo:datetime/DateTime";
import IterTools "mo:itertools/Iter";
import Stadium "../Stadium";

actor class DivisionActor(leagueId : Principal, stadiumId : Principal) : async Division.DivisionActor = this {
    type TeamWithId = Team.TeamWithId;
    type Team = Team.TeamWithoutDivision;
    type CreateTeamResult = Division.CreateTeamResult;
    type CreateTeamRequest = Division.CreateTeamRequest;
    type LedgerActor = Token.Token;
    type Prng = PseudoRandomX.PseudoRandomGenerator;
    type SeasonSchedule = Division.SeasonSchedule;

    stable var teams : Trie.Trie<Principal, Team> = Trie.empty();
    stable var schedule : ?SeasonSchedule = null;
    let stadium = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;

    public query func getTeams() : async [TeamWithId] {
        Trie.toArray(
            teams,
            func(k : Principal, v : Team) : TeamWithId = {
                id = k;
                name = v.name;
                logoUrl = v.logoUrl;
                ledgerId = v.ledgerId;
                divisionId = Principal.fromActor(this);
            },
        );
    };

    public shared ({ caller }) func createTeam(request : CreateTeamRequest) : async CreateTeamResult {

        let nameAlreadyTaken = Trie.some(
            teams,
            func(k : Principal, v : Team) : Bool = v.name == request.name,
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };
        // Create canister for team ledger
        let ledger : LedgerActor = await createTeamLedger(request.tokenName, request.tokenSymbol);
        let ledgerId = Principal.fromActor(ledger);
        // Create canister for team logic
        let teamActor = await createTeamActor(ledgerId);
        let teamId = Principal.fromActor(teamActor);
        let team : Team = {
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

    public shared ({ caller }) func mint(request : Division.MintRequest) : async Division.MintResult {
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

    public shared ({ caller }) func updateDivisionCanisters() : async () {
        for ((teamId, team) in Trie.iter(teams)) {
            let teamActor = actor (Principal.toText(teamId)) : Team.TeamActor;
            let divisionId = Principal.fromActor(this);
            let ledgerId = team.ledgerId;
            let _ = await (system TeamActor.TeamActor)(#upgrade(teamActor))(leagueId, stadiumId, divisionId, ledgerId);
        };
    };

    private func createTeamActor(ledgerId : Principal) : async TeamActor.TeamActor {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let divisionId = Principal.fromActor(this);
        await TeamActor.TeamActor(
            leagueId,
            stadiumId,
            divisionId,
            ledgerId,
        );
    };

    private func createTeamLedger(tokenName : Text, tokenSymbol : Text) : async LedgerActor {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);

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
};
