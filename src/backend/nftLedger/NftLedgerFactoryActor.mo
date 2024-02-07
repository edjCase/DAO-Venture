import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Types "Types";
import NftLedgerActor "NftLedgerActor";

actor NftLedgerFactoryActor {

    stable var leagueIdOrNull : ?Principal = null;

    stable var ledgers = Trie.empty<Principal, Types.NftLedgerActorInfo>();

    public shared ({ caller }) func setLeague(id : Principal) : async Types.SetLeagueResult {
        // TODO how to get the league id vs manual set
        // Set if the league is not set or if the caller is the league
        if (leagueIdOrNull == null or leagueIdOrNull == ?caller) {
            leagueIdOrNull := ?id;
            return #ok;
        };
        #notAuthorized;
    };

    public func getLedgers() : async [Types.NftLedgerActorInfoWithId] {
        ledgers
        |> Trie.iter(_)
        |> Iter.map(
            _,
            func((id, info) : (Principal, Types.NftLedgerActorInfo)) : Types.NftLedgerActorInfoWithId = {
                info with id = id;
            },
        )
        |> Iter.toArray(_);
    };

    public func createNftLedger() : async Types.CreateNftLedgerResult {
        let ?leagueId = leagueIdOrNull else Debug.trap("League id not set");
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let ledger = try {
            await NftLedgerActor.NftLedgerActor(leagueId);
        } catch (err) {
            return #ledgerCreationError(Error.message(err));
        };
        let ledgerId = Principal.fromActor(ledger);
        let ledgerKey = {
            key = ledgerId;
            hash = Principal.hash(ledgerId);
        };
        let (newLedgers, _) = Trie.put(ledgers, ledgerKey, Principal.equal, {});
        ledgers := newLedgers;
        #ok(ledgerId);
    };

    public func updateCanisters() : async () {
        for ((ledgerId, ledgerInfo) in Trie.iter(ledgers)) {
            let ledgerActor = actor (Principal.toText(ledgerId)) : Types.NftLedgerActor;
            try {
                let _ = await (system NftLedgerActor.NftLedgerActor)(#upgrade(ledgerActor))(leagueId);
            } catch (err) {
                // Dont trap to allow the others to be upgraded
                Debug.print("Error upgrading ledger actor: " # Error.message(err));
            };
        };
    };

};
