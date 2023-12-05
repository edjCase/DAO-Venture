import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Types "Types";
import StadiumActor "StadiumActor";

actor StadiumFactoryActor {

    let leagueId : Principal = Principal.fromText("bkyz2-fmaaa-aaaaa-qaaaq-cai"); // TODO dont hard code

    stable var stadiums = Trie.empty<Principal, Types.StadiumActorInfo>();

    public func getStadiums() : async [Types.StadiumActorInfoWithId] {
        stadiums
        |> Trie.iter(_)
        |> Iter.map(
            _,
            func((id, info) : (Principal, Types.StadiumActorInfo)) : Types.StadiumActorInfoWithId = {
                info with id = id;
            },
        )
        |> Iter.toArray(_);
    };

    public func createStadiumActor() : async Types.CreateStadiumResult {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let stadium = try {
            await StadiumActor.StadiumActor(leagueId);
        } catch (err) {
            return #stadiumCreationError(Error.message(err));
        };
        let stadiumId = Principal.fromActor(stadium);
        let stadiumKey = {
            key = stadiumId;
            hash = Principal.hash(stadiumId);
        };
        let (newStadiums, _) = Trie.put(stadiums, stadiumKey, Principal.equal, {});
        stadiums := newStadiums;
        #ok(stadiumId);
    };

    public func updateCanisters() : async () {
        for ((stadiumId, stadiumInfo) in Trie.iter(stadiums)) {
            let stadiumActor = actor (Principal.toText(stadiumId)) : Types.StadiumActor;
            try {
                let _ = await (system StadiumActor.StadiumActor)(#upgrade(stadiumActor))(leagueId);
            } catch (err) {
                Debug.print("Error upgrading stadium actor: " # Error.message(err));
            };
        };
    };

};
