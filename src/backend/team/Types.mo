import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "../models/Player";
import StadiumTypes "../stadium/Types";
import Offering "../models/Offering";

module {
    public type TeamActor = actor {
        getPlayers : composite query () -> async [Player.PlayerWithId];
        getMatchGroupVote : query (matchGroupId : Nat32) -> async GetMatchGroupVoteResult;
        voteOnMatchGroup : (request : VoteOnMatchGroupRequest) -> async VoteOnMatchGroupResult;
    };

    public type MatchVoteResult = {
        offeringVotes : Trie.Trie<Offering.Offering, Nat>;
        championVotes : Trie.Trie<Player.PlayerId, Nat>;
    };

    public type MatchOptionsCallback = shared query (stadiumId : Principal, matchId : Nat32) -> async ?MatchVoteResult;

    public type MatchGroupVoteResult = {
        offering : Offering.Offering;
        championId : Player.PlayerId;
    };

    public type GetMatchGroupVoteResult = {
        #ok : MatchGroupVoteResult;
        #noVotes;
        #notAuthorized;
    };

    public type GetCyclesResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type MatchGroupVote = {
        offering : Offering.Offering;
        championId : Player.PlayerId;
    };

    public type VoteOnMatchGroupRequest = MatchGroupVote and {
        matchGroupId : Nat32;
    };

    public type VoteOnMatchGroupResult = {
        #ok;
        #notAuthorized;
        #matchGroupNotFound;
        #votingNotOpen;
        #teamNotInMatchGroup;
        #alreadyVoted;
        #seasonStatusFetchError : Text;
        #invalid : [InvalidVoteError];
    };

    public type InvalidVoteError = {
        #invalidChampionId : Player.PlayerId;
        #invalidOffering : Offering.Offering;
    };
};