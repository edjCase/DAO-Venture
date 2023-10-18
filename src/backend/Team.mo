import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "Player";

module {
    public type TeamActor = actor {
        getPlayers : shared composite query () -> async [Player.PlayerWithId];
        getMatchOptions : shared query (stadiumId : Principal, matchId : Nat32) -> async GetMatchOptionsResult;
        updateMatchOptions : shared (stadiumId : Principal, matchId : Nat32, options : MatchOptions) -> async UpdateMatchOptionsResult;
    };

    public type MatchVoteResult = {
        offeringIdVotes : Trie.Trie<Nat32, Nat>;
        specialRuleVotes : Trie.Trie<Nat32, Nat>;
    };

    public type MatchOptionsCallback = shared query (stadiumId : Principal, matchId : Nat32) -> async ?MatchVoteResult;

    public type GetMatchOptionsResult = {
        #ok : MatchOptions;
        #noVotes;
        #notAuthorized;
    };

    public type MatchOptions = {
        offeringId : Nat32;
        specialRuleVotes : [(Nat32, Nat)];
    };

    public type UpdateMatchOptionsResult = {
        #ok;
        #notAuthorized;
        #matchNotFound;
        #stadiumNotFound;
        #teamNotInMatch;
        #invalid : [Text];
    };

    public type Team = {
        canister : TeamActor;
        name : Text;
        logoUrl : Text;
    };
};
