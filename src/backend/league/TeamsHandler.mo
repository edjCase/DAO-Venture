import Team "../models/Team";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import Debug "mo:base/Debug";
import Int "mo:base/Int";
import Types "Types";
import IterTools "mo:itertools/Iter";
import TeamFactoryActor "canister:teamFactory";
import PlayersActor "canister:players";
import TeamTypes "../team/Types";

module {

    public type Data = {
        teams : [Team.TeamWithId];
        teamFactoryInitialized : Bool;
    };
    public class Handler(leagueId : Principal, data : Data) {
        var teams : HashMap.HashMap<Principal, Team.Team> = toTeamHashMap(data.teams);
        var teamFactoryInitialized = data.teamFactoryInitialized;

        public func toStableData() : Data {
            let teams = getAll();
            return {
                teams = teams;
                teamFactoryInitialized = teamFactoryInitialized;
            };
        };

        public func getAll() : [Team.TeamWithId] {
            teams.entries()
            |> Iter.map(
                _,
                func((k, v) : (Principal, Team.Team)) : Team.TeamWithId = {
                    v with
                    id = k;
                },
            )
            |> Iter.toArray(_);
        };

        public func updateTeamEnergy(teamId : Principal, delta : Int) : () {
            let ?team = teams.get(teamId) else Debug.trap("Team not found: " # Principal.toText(teamId));
            let newTeam : Team.Team = {
                team with
                energy = team.energy + delta;
            };
            teams.put(teamId, newTeam);
        };

        public func updateTeamEntropy(teamId : Principal, delta : Int) : () {
            let ?team = teams.get(teamId) else Debug.trap("Team not found: " # Principal.toText(teamId));
            let newEntropyInt : Int = team.entropy + delta;
            let newEntropyNat : Nat = if (newEntropyInt <= 0) {
                // Entropy cant be negative
                0;
            } else {
                Int.abs(newEntropyInt);
            };
            let newTeam : Team.Team = {
                team with
                entropy = newEntropyNat;
            };
            teams.put(teamId, newTeam);
        };

        public func create(request : Types.CreateTeamRequest) : async* Types.CreateTeamResult {
            let nameAlreadyTaken = teams.entries()
            |> IterTools.any(
                _,
                func((k, v) : (Principal, Team.Team)) : Bool = v.name == request.name,
            );

            if (nameAlreadyTaken) {
                return #nameTaken;
            };
            if (not teamFactoryInitialized) {
                let #ok = await TeamFactoryActor.setLeague(leagueId) else Debug.trap("Failed to set league on team factory");
                teamFactoryInitialized := true;
            };
            let createTeamResult = try {
                await TeamFactoryActor.createTeamActor(request);
            } catch (err) {
                return #teamFactoryCallError(Error.message(err));
            };
            let teamInfo = switch (createTeamResult) {
                case (#ok(teamInfo)) teamInfo;
            };
            let team : Team.Team = {
                name = request.name;
                logoUrl = request.logoUrl;
                motto = request.motto;
                description = request.description;
                entropy = 0; // TODO
                energy = 0;
                color = request.color;
            };
            teams.put(teamInfo.id, team);

            let populateResult = try {
                await PlayersActor.populateTeamRoster(teamInfo.id);
            } catch (err) {
                return #populateTeamRosterCallError(Error.message(err));
            };
            switch (populateResult) {
                case (#ok(_)) {};
                case (#notAuthorized) {
                    Debug.print("Error populating team roster: League is not authorized to populate team roster for team: " # Principal.toText(teamInfo.id));
                };
                case (#noMorePlayers) {
                    Debug.print("Error populating team roster: No more players available");
                };
            };
            return #ok(teamInfo.id);
        };

        public func onSeasonComplete() : async* () {
            for ((teamId, _) in teams.entries()) {
                let teamActor = actor (Principal.toText(teamId)) : TeamTypes.TeamActor;
                try {
                    switch (await teamActor.onSeasonComplete()) {
                        case (#ok) ();
                        case (#notAuthorized) Debug.print("Error: League is not authorized to notify team of season completion");
                    };
                } catch (err) {
                    Debug.print("Failed to notify team of season completion: " # Error.message(err));
                };
            };
        };
    };

    private func toTeamHashMap(teams : [Team.TeamWithId]) : HashMap.HashMap<Principal, Team.Team> {
        var result = HashMap.HashMap<Principal, Team.Team>(0, Principal.equal, Principal.hash);
        for (team in Iter.fromArray(teams)) {
            result.put(team.id, team);
        };
        return result;
    };
};
