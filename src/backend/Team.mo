import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "Player";
import Stadium "Stadium";

module {
    public type TeamActor = actor {
        getPlayers : composite query () -> async [Player.PlayerWithId];
        getMatchOptions : query (stadiumId : Principal, matchId : Nat32) -> async GetMatchOptionsResult;
        voteForMatchOptions : (request : VoteForMatchOptionsRequest) -> async VoteForMatchOptionsResult;
    };

    public type MatchVoteResult = {
        offeringVotes : Trie.Trie<Stadium.Offering, Nat>;
        specialRuleVotes : Trie.Trie<Stadium.SpecialRule, Nat>;
    };

    public type MatchOptionsCallback = shared query (stadiumId : Principal, matchId : Nat32) -> async ?MatchVoteResult;

    public type GetMatchOptionsResult = {
        #ok : Stadium.MatchOptions;
        #noVotes;
        #notAuthorized;
    };

    public type GetCyclesResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type MatchOptionsVote = {
        offering : Stadium.Offering;
        specialRule : Stadium.SpecialRule;
    };

    public type VoteForMatchOptionsRequest = {
        stadiumId : Principal;
        matchId : Nat32;
        vote : MatchOptionsVote;
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
