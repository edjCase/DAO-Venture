import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Types "Types";
import StadiumActor "StadiumActor";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";

actor {

    stable var leagueIdOrNull : ?Principal = null;

    stable var stadiums = Trie.empty<Principal, Types.StadiumActorInfo>();

    public shared ({ caller }) func setLeague(id : Principal) : async Types.SetLeagueResult {
        // TODO how to get the league id vs manual set
        // Set if the league is not set or if the caller is the league
        if (leagueIdOrNull == null or leagueIdOrNull == ?caller) {
            leagueIdOrNull := ?id;
            return #ok;
        };
        #notAuthorized;
    };

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
        let ?leagueId = leagueIdOrNull else Debug.trap("League id not set");
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add<system>(canisterCreationCost + initialBalance);
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
        if (Trie.size(stadiums) > 0) {
            let ?leagueId = leagueIdOrNull else Debug.trap("League id not set");
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

};
