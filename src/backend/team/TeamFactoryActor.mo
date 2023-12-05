import TeamActor "TeamActor";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Types "Types";
import ICRC1TokenCanister "mo:icrc1/ICRC1/Canisters/Token";

actor TeamFactoryActor {
    type TeamLedgerActor = ICRC1TokenCanister.Token;

    let leagueId : Principal = Principal.fromText("bkyz2-fmaaa-aaaaa-qaaaq-cai"); // TODO dont hard code

    stable var teams = Trie.empty<Principal, Types.TeamActorInfo>();

    public func getTeams() : async [Types.TeamActorInfoWithId] {
        teams
        |> Trie.iter(_)
        |> Iter.map(
            _,
            func((id, info) : (Principal, Types.TeamActorInfo)) : Types.TeamActorInfoWithId = {
                info with id = id;
            },
        )
        |> Iter.toArray(_);
    };

    public func createTeamActor(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
        // TODO handle states where ledger exists but the team actor doesn't
        // Create canister for team ledger
        // Create canister for team logic
        let ledger : TeamLedgerActor = await createTeamLedger(request.tokenName, request.tokenSymbol);
        let ledgerId = Principal.fromActor(ledger);
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 100_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let teamActor = await TeamActor.TeamActor(
            leagueId,
            ledgerId,
        );
        let teamId = Principal.fromActor(teamActor);
        let teamKey = {
            key = teamId;
            hash = Principal.hash(teamId);
        };
        let (newTeams, _) = Trie.put(teams, teamKey, Principal.equal, { ledgerId = ledgerId });
        teams := newTeams;
        #ok({
            id = teamId;
            ledgerId = ledgerId;
        });
    };

    public func updateCanisters() : async () {
        for ((teamId, teamInfo) in Trie.iter(teams)) {
            let teamActor = actor (Principal.toText(teamId)) : Types.TeamActor;

            try {
                let _ = await (system TeamActor.TeamActor)(#upgrade(teamActor))(
                    teamId, // Dummy argument, update doesn't use them
                    teamId, // Dummy argument, update doesn't use them
                );
            } catch (err) {
                Debug.print("Error upgrading team actor: " # Error.message(err));
            };
        };
    };

    private func createTeamLedger(tokenName : Text, tokenSymbol : Text) : async TeamLedgerActor {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);

        await ICRC1TokenCanister.Token({
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
};
