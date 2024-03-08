import TeamActor "TeamActor";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Iter "mo:base/Iter";
import Types "Types";
import UsersActor "canister:users";

actor TeamFactoryActor {

    stable var leagueIdOrNull : ?Principal = null;

    stable var teams = Trie.empty<Principal, Types.TeamActorInfo>();

    public shared ({ caller }) func setLeague(id : Principal) : async Types.SetLeagueResult {
        // TODO how to get the league id vs manual set
        // Set if the league is not set or if the caller is the league
        if (leagueIdOrNull == null or leagueIdOrNull == ?caller) {
            leagueIdOrNull := ?id;
            return #ok;
        };
        #notAuthorized;
    };

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
        let ?leagueId = leagueIdOrNull else Debug.trap("League id not set");
        // Create canister for team logic
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 100_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let teamActor = await TeamActor.TeamActor(
            leagueId,
            Principal.fromActor(UsersActor),
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
        if (Trie.size(teams) > 0) {
            let ?leagueId = leagueIdOrNull else Debug.trap("League id not set");
            for ((teamId, teamInfo) in Trie.iter(teams)) {
                let teamActor = actor (Principal.toText(teamId)) : Types.TeamActor;

                try {
                    let _ = await (system TeamActor.TeamActor)(#upgrade(teamActor))(
                        leagueId,
                        Principal.fromActor(UsersActor),
                    );
                } catch (err) {
                    Debug.print("Error upgrading team actor: " # Error.message(err));
                };
            };
        };
    };

};
