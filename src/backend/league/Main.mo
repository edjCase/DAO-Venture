import Team "../Team";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Cycles "mo:base/ExperimentalCycles";
import IterTools "mo:itertools/Iter";
import Hash "mo:base/Hash";
import Player "../Player";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Stadium "../Stadium";
import TeamCanister "../team/Main";
import StadiumCanister "../stadium/Main";
import { ic } "mo:ic";
import Time "mo:base/Time";

actor LeagueActor {

    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
    };
    public type CreateStadiumResult = {
        #ok : Principal;
    };
    public type ScheduleMatchResult = Stadium.ScheduleMatchResult or {
        #stadiumNotFound;
    };
    public type TeamInfo = {
        id : Principal;
        name : Text;
        logoUrl : Text;
    };
    public type StadiumInfo = {
        id : Principal;
        name : Text;
    };

    stable var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var stadiums : Trie.Trie<Principal, Stadium.Stadium> = Trie.empty();
    stable var nextPlayerId : Nat = 0;

    public type TeamInitializationConfig = {
        name : Text;
    };

    public query func getTeams() : async [TeamInfo] {
        Trie.toArray(
            teams,
            func(k : Principal, v : Team.Team) : TeamInfo = {
                id = k;
                name = v.name;
                logoUrl = v.logoUrl;
            },
        );
    };
    public query func getStadiums() : async [StadiumInfo] {
        Trie.toArray(
            stadiums,
            func(k : Principal, v : Stadium.Stadium) : StadiumInfo = {
                id = k;
                name = v.name;
            },
        );
    };

    public shared ({ caller }) func createTeam(name : Text, logoUrl : Text) : async CreateTeamResult {

        let nameAlreadyTaken = Trie.some(
            teams,
            func(k : Principal, v : Team.Team) : Bool {
                v.name == name;
            },
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };

        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 3_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let teamActor = await TeamCanister.TeamActor(Principal.fromActor(LeagueActor), caller);
        let team : Team.Team = {
            name = name;
            canister = teamActor;
            logoUrl = logoUrl;
        };
        let teamId = Principal.fromActor(teamActor);
        let teamKey = buildKey(teamId);
        switch (Trie.put(teams, teamKey, Principal.equal, team)) {
            case (_, ?previous) Prelude.unreachable(); // No way new id can conflict with existing one
            case (newTeams, null) {
                teams := newTeams;
                return #ok(teamId);
            };
        };
    };

    public shared ({ caller }) func createStadium(name : Text) : async CreateStadiumResult {
        // TODO validate name

        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 3_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let stadiumCanister = await StadiumCanister.StadiumActor(Principal.fromActor(LeagueActor));
        let stadium : Stadium.Stadium = {
            name = name;
            canister = stadiumCanister;
        };

        let stadiumId = Principal.fromActor(stadiumCanister);
        let stadiumKey = buildKey(stadiumId);
        switch (Trie.put(stadiums, stadiumKey, Principal.equal, stadium)) {
            case (_, ?previous) Prelude.unreachable(); // No way new id can conflict with existing one
            case (newStadiums, null) {
                stadiums := newStadiums;
                return #ok(stadiumId);
            };
        };
    };

    public shared ({ caller }) func scheduleMatch(
        stadiumId : Principal,
        teamIds : (Principal, Principal),
        time : Time.Time,
    ) : async ScheduleMatchResult {
        let ?stadium = Trie.get(stadiums, buildKey(stadiumId), Principal.equal) else return #stadiumNotFound;
        await stadium.canister.scheduleMatch(teamIds, time);
    };

    public shared ({ caller }) func updateLeagueCanisters() : async () {
        let leagueId = Principal.fromActor(LeagueActor);
        for ((teamId, team) in Trie.iter(teams)) {
            let ownerId = caller; // TODO - get owner from team
            let _ = await (system TeamCanister.TeamActor)(#upgrade(team.canister))(leagueId, ownerId);
        };
        for ((stadiumId, stadium) in Trie.iter(stadiums)) {
            let _ = await (system StadiumCanister.StadiumActor)(#upgrade(stadium.canister))(leagueId);
        };
    };

    private func buildKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };
};
