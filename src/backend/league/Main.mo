import Team "../Team";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Cycles "mo:base/ExperimentalCycles";
import IterTools "mo:itertools/Iter";
import Hash "mo:base/Hash";
import TeamInstance "../team/Main";
import Player "../Player";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";

actor League {

    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
    };

    var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();
    stable var nextPlayerId : Nat = 0;

    public type TeamInitializationConfig = {
        name : Text;
    };

    public type LeageInitializationConfig = {
        teams : [TeamInitializationConfig];
    };

    public shared func initialize(config : LeageInitializationConfig) : async {
        #ok;
        #alreadyInitialized;
    } {
        Cycles.add(10_000_000_000_000); // TODO
        #ok;
    };

    public shared func createTeam(name : Text) : async CreateTeamResult {
        Cycles.add(10_000_000_000_000); // TODO

        let nameAlreadyTaken = Trie.some(
            teams,
            func(k : Principal, v : Team.Team) : Bool {
                v.name == name;
            },
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };
        // TODO prevent name from being taken while we're creating the team
        // TODO make a 'pending' list of teams that are being created
        let players = generatePlayers(26);
        let teamActor = await TeamInstance.TeamActor(Principal.fromActor(League), players);
        let team : Team.Team = {
            name = name;
            canister = teamActor;
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

    private func generatePlayers(count : Nat) : [Player.Player] {
        let nextPlayerIds = IterTools.range(nextPlayerId, count);
        nextPlayerId := nextPlayerId + count;
        let playersIter = IterTools.mapEntries(
            nextPlayerIds,
            func(i : Nat, id : Nat) : Player.Player = generatePlayer(id),
        );
        Iter.toArray(playersIter);
    };

    private func generatePlayer(id : Nat) : Player.Player {
        let name = generateName(id);
        {
            id = Nat32.fromNat(id); // TODO Nat vs Nat32
            name = name;
        };
    };

    private func generateName(id : Nat) : Text {
        "Player " # Nat.toText(id);
    };

    private func buildKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };
};
