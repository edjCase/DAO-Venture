import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "../models/Player";
import StadiumTypes "../stadium/Types";

module {

    public type TeamActor = actor {
        getPlayers : composite query () -> async [Player.PlayerWithId];
        getMatchGroupVote : query (matchGroupId : Nat) -> async GetMatchGroupVoteResult;
        voteOnMatchGroup : (request : VoteOnMatchGroupRequest) -> async VoteOnMatchGroupResult;
    };

    public type TeamFactoryActor = actor {
        setLeague : (id : Principal) -> async SetLeagueResult;
        createTeamActor : (request : CreateTeamRequest) -> async CreateTeamResult;
        getTeamActors : () -> async [TeamActorInfoWithId];
        updateCanisters : () -> async ();
    };

    public type SetLeagueResult = {
        #ok;
        #notAuthorized;
    };

    public type TeamActorInfo = {};

    public type TeamActorInfoWithId = TeamActorInfo and { id : Principal };

    public type CreateTeamRequest = {
        tokenName : Text;
        tokenSymbol : Text;
    };

    public type CreateTeamResult = {
        #ok : {
            id : Principal;
        };
    };

    public type MatchVoteResult = {
        votes : [Nat];
    };

    public type MatchGroupVoteResult = {
        scenarioChoice : Nat8;
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
        scenarioChoice : Nat8;
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
        #invalidChoice : Nat8;
    };
};
