import Team "../models/Team";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Types "Types";
import IterTools "mo:itertools/Iter";
import TeamsActor "canister:teams";
import PlayersActor "canister:players";

module {

    public type Team = {
        id : Nat;
    };

    public type StableData = {
        teams : [Team];
        teamsInitialized : Bool;
    };
    public class Handler(data : StableData) {
        var teams : HashMap.HashMap<Nat, Team> = toTeamHashMap(data.teams);
        var teamsInitialized = data.teamsInitialized;

        public func toStableData() : StableData {
            let teams = getAll();
            return {
                teams = teams;
                teamsInitialized = teamsInitialized;
            };
        };

        public func getAll() : [Team] {
            teams.vals()
            |> Iter.toArray(_);
        };

        public func onSeasonEnd() : async* () {
            try {
                switch (await TeamsActor.onSeasonEnd()) {
                    case (#ok) ();
                    case (#notAuthorized) Debug.print("Error: League is not authorized to notify team of season completion");
                };
            } catch (err) {
                Debug.print("Failed to notify team of season completion: " # Error.message(err));
            };
        };
    };

    private func toTeamHashMap(teams : [Team]) : HashMap.HashMap<Nat, Team> {
        var result = HashMap.HashMap<Nat, Team>(0, Nat.equal, Nat32.fromNat);
        for (team in Iter.fromArray(teams)) {
            result.put(team.id, team);
        };
        return result;
    };
};
