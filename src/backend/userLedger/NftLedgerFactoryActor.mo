import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Types "Types";
import NftLedgerActor "NftLedgerActor";

actor NftLedgerFactoryActor {

    let leagueId : Principal = Principal.fromText("bkyz2-fmaaa-aaaaa-qaaaq-cai"); // TODO dont hard code

    stable var ledgers = Trie.empty<Principal, Types.NftLedgerActorInfo>();

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
