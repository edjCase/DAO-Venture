import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "../models/Player";
import StadiumTypes "../stadium/Types";
import Offering "../models/Offering";

module {

    public type TeamActor = actor {
        getPlayers : composite query () -> async [Player.TeamPlayerWithId];
        getMatchGroupVote : query (matchGroupId : Nat) -> async GetMatchGroupVoteResult;
        voteOnMatchGroup : (request : VoteOnMatchGroupRequest) -> async VoteOnMatchGroupResult;
    };

    public type TeamFactoryActor = actor {
        createTeamActor : (request : CreateTeamRequest) -> async CreateTeamResult;
        getTeamActors : () -> async [TeamActorInfoWithId];
        updateCanisters : () -> async ();
    };

    public type TeamActorInfo = { ledgerId : Principal };

    public type TeamActorInfoWithId = TeamActorInfo and { id : Principal };

    public type CreateTeamRequest = {
        tokenName : Text;
        tokenSymbol : Text;
    };

    public type CreateTeamResult = {
        #ok : {
            id : Principal;
            ledgerId : Principal;
        };
    };

    public type MatchVoteResult = {
        offeringVotes : Trie.Trie<Offering.Offering, Nat>;
        championVotes : Trie.Trie<Player.PlayerId, Nat>;
    };

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
        matchGroupId : Nat;
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
