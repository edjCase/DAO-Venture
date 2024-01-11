import TeamActor "TeamActor";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Types "Types";

actor TeamFactoryActor {

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
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 100_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let teamActor = await TeamActor.TeamActor(
            leagueId
        );
        let teamId = Principal.fromActor(teamActor);
        let teamKey = {
            key = teamId;
            hash = Principal.hash(teamId);
        };
        let (newTeams, _) = Trie.put(teams, teamKey, Principal.equal, {});
        teams := newTeams;
        #ok({
            id = teamId;
        });
    };

    public func updateCanisters() : async () {
        for ((teamId, teamInfo) in Trie.iter(teams)) {
            let teamActor = actor (Principal.toText(teamId)) : Types.TeamActor;

            try {
                let _ = await (system TeamActor.TeamActor)(#upgrade(teamActor))(
                    teamId, // Dummy argument, update doesn't use them
                );
            } catch (err) {
                Debug.print("Error upgrading team actor: " # Error.message(err));
            };
        };
    };

};
