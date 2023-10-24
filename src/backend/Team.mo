import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "Player";

module {
    public type TeamActor = actor {
        getPlayers : composite query () -> async [Player.PlayerWithId];
        getMatchOptions : query (stadiumId : Principal, matchId : Nat32) -> async GetMatchOptionsResult;
        voteForMatchOptions : (stadiumId : Principal, matchId : Nat32, vote : MatchOptionsVote) -> async VoteForMatchOptionsResult;
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

    public type GetCyclesResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type MatchOptionsVote = {
        offeringId : Nat32;
        specialRuleId : Nat32;
    };

    public type MatchOptions = {
        offeringId : Nat32;
        specialRuleVotes : [(Nat32, Nat)];
    };

    public type VoteForMatchOptionsResult = {
        #ok;
        #notAuthorized;
        #matchNotFound;
        #stadiumNotFound;
        #teamNotInMatch;
        #alreadyVoted;
        #invalid : [Text];
    };

    public type Team = {
        name : Text;
        logoUrl : Text;
        ledgerId : Principal;
        divisionId : Nat32;
    };
};
