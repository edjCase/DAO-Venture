import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "Player";

module {
    public type TeamActor = actor {
        getPlayers : shared composite query () -> async [Player.Player];
        getMatchOptions : shared query (matchId : Nat32) -> async ?MatchOptions;
    };

    public type MatchOptions = {
        offeringId : Nat32;
        specialRuleVotes : Trie.Trie<Nat32, Nat>;
    };

    public type Team = {
        canister : TeamActor;
        name : Text;
        logoUrl : Text;
    };
};
