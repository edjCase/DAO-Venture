import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "Player";
import Stadium "Stadium";

module {
    public type TeamActor = actor {
        getPlayers : composite query () -> async [Player.PlayerWithId];
        getMatchGroupVote : query (matchGroupId : Nat32) -> async GetMatchGroupVoteResult;
        voteOnMatchGroup : (request : VoteOnMatchGroupRequest) -> async VoteOnMatchGroupResult;
    };

    public type MatchVoteResult = {
        offeringVotes : Trie.Trie<Stadium.Offering, Nat>;
        championVotes : Trie.Trie<Player.PlayerId, Nat>;
    };

    public type MatchOptionsCallback = shared query (stadiumId : Principal, matchId : Nat32) -> async ?MatchVoteResult;

    public type GetMatchGroupVoteResult = {
        #ok : Stadium.MatchOptions;
        #noVotes;
        #notAuthorized;
    };

    public type GetCyclesResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type MatchGroupVote = {
        offering : Stadium.Offering;
        champion : Player.PlayerId;
    };

    public type VoteOnMatchGroupRequest = MatchGroupVote and {
        matchGroupId : Nat32;
    };

    public type VoteOnMatchGroupResult = {
        #ok;
        #notAuthorized;
        #matchGroupNotFound;
        #teamNotInMatchGroup;
        #alreadyVoted;
        #matchGroupFetchError : Text;
        #invalid : [Text];
    };

    public type TeamWithoutDivision = {
        name : Text;
        logoUrl : Text;
        ledgerId : Principal;
    };

    public type Team = TeamWithoutDivision and {
        divisionId : Principal;
    };

    public type TeamWithId = Team and {
        id : Principal;
    };
};
