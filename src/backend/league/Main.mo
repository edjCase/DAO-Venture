import Team "../team/Main";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Cycles "mo:base/ExperimentalCycles";

actor League {
    var teams : Trie.Trie<Principal, Team.Team> = Trie.empty();

    public shared func createTeam(name : Text) : async Principal {
        Cycles.add(10_000_000_000_000);
        let team = await Team.Team(name);
        let teamId = Principal.fromActor(team);
        let (newTeams, previousValue) = Trie.put(teams, { key = teamId; hash = Principal.hash(teamId) }, Principal.equal, team);
        if (previousValue != null) {
            Prelude.unreachable();
        };
        teams := newTeams;
        return teamId;
    };
};
