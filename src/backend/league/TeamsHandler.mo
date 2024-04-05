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
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        entropy : Nat;
        color : (Nat8, Nat8, Nat8);
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

        public func updateTeamName(teamId : Nat, newName : Text) : () {
            updateTeamInternal(
                teamId,
                func(team : Team) : Team = {
                    team with
                    name = newName;
                },
            );
        };

        public func updateTeamColor(teamId : Nat, color : (Nat8, Nat8, Nat8)) : () {
            updateTeamInternal(
                teamId,
                func(team : Team) : Team = {
                    team with
                    color = color;
                },
            );
        };

        public func updateTeamLogo(teamId : Nat, logoUrl : Text) : () {
            updateTeamInternal(
                teamId,
                func(team : Team) : Team = {
                    team with
                    logoUrl = logoUrl;
                },
            );
        };

        public func updateTeamMotto(teamId : Nat, motto : Text) : () {
            updateTeamInternal(
                teamId,
                func(team : Team) : Team = {
                    team with
                    motto = motto;
                },
            );
        };

        public func updateTeamDescription(teamId : Nat, description : Text) : () {
            updateTeamInternal(
                teamId,
                func(team : Team) : Team = {
                    team with
                    description = description;
                },
            );
        };

        public func updateTeamEntropy(teamId : Nat, delta : Int) : () {
            updateTeamInternal(
                teamId,
                func(team : Team) : Team {
                    let newEntropyInt : Int = team.entropy + delta;
                    let newEntropyNat : Nat = if (newEntropyInt <= 0) {
                        // Entropy cant be negative
                        0;
                    } else {
                        Int.abs(newEntropyInt);
                    };
                    {
                        team with
                        entropy = newEntropyNat;
                    };
                },
            );
        };

        private func updateTeamInternal(teamId : Nat, updateFunc : (Team) -> Team) : () {
            let ?team = teams.get(teamId) else Debug.trap("Team not found: " # Nat.toText(teamId));
            let newTeam = updateFunc(team);
            teams.put(teamId, newTeam);
        };

        public func create(
            leagueId : Principal, // TODO this should be part of the data, but we don't have a way to pass it in yet
            request : Types.CreateTeamRequest,
        ) : async* Types.CreateTeamResult {
            let nameAlreadyTaken = teams.entries()
            |> IterTools.any(
                _,
                func((_, v) : (Nat, Team.Team)) : Bool = v.name == request.name,
            );

            if (nameAlreadyTaken) {
                return #nameTaken;
            };
            if (not teamsInitialized) {
                let #ok = await TeamsActor.setLeague(leagueId) else Debug.trap("Failed to set league on teams actor");
                teamsInitialized := true;
            };
            let createTeamResult = try {
                await TeamsActor.createTeam(request);
            } catch (err) {
                return #teamsCallError(Error.message(err));
            };
            let teamInfo = switch (createTeamResult) {
                case (#ok(teamInfo)) teamInfo;
                case (#notAuthorized) return #notAuthorized;
            };
            let team : Team = {
                id = teamInfo.id;
                name = request.name;
                logoUrl = request.logoUrl;
                motto = request.motto;
                description = request.description;
                entropy = 0; // TODO
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
                    Debug.print("Error populating team roster: League is not authorized to populate team roster for team: " # Nat.toText(teamInfo.id));
                };
                case (#missingFluff) {
                    Debug.print("Error populating team roster: No unused player fluff available");
                };
            };
            return #ok(teamInfo.id);
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
