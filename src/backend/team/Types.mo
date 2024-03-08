import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "../models/Player";
import StadiumTypes "../stadium/Types";
import Dao "../Dao";
import Skill "../models/Skill";

module {

    public type TeamActor = actor {
        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;
        addMember : (request : AddMemberRequest) -> async AddMemberResult;
        getMembers : query () -> async [Member];
        createProposal : (request : CreateProposalRequest) -> async CreateProposalResult;
        getProposal : query (id : Nat) -> async ?Proposal;
        getProposals : query () -> async [Proposal];
        voteOnProposal : (request : VoteOnProposalRequest) -> async VoteOnProposalResult;
        getWinningScenarioOption : (request : GetWinningScenarioOptionRequest) -> async GetWinningScenarioOptionResult;
        onNewScenario : (request : OnNewScenarioRequest) -> async OnNewScenarioResult;
        onScenarioVoteComplete : (request : OnScenarioVoteCompleteRequest) -> async OnScenarioVoteCompleteResult;
        onSeasonComplete() : async OnSeasonCompleteResult;
    };

    public type TeamFactoryActor = actor {
        setLeague : (id : Principal) -> async SetLeagueResult;
        createTeamActor : (request : CreateTeamRequest) -> async CreateTeamResult;
        getTeamActors : () -> async [TeamActorInfoWithId];
        updateCanisters : () -> async ();
    };

    public type Member = Dao.Member;

    public type AddMemberRequest = {
        id : Principal;
    };

    public type AddMemberResult = {
        #ok;
        #notAuthorized;
        #alreadyExists;
    };

    public type VoteOnProposalRequest = {
        proposalId : Nat;
        vote : Bool;
    };

    public type VoteOnProposalResult = {
        #ok;
        #notAuthorized;
        #proposalNotFound;
        #alreadyVoted;
        #votingClosed;
    };

    public type Proposal = Dao.Proposal<ProposalContent>;

    public type ProposalContent = {
        #trainPlayer : {
            playerId : Nat32;
            skill : Skill.Skill;
        };
    };

    public type CreateProposalRequest = {
        content : ProposalContent;
    };

    public type CreateProposalResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type OnScenarioVoteCompleteRequest = {
        scenarioId : Text;
    };

    public type OnScenarioVoteCompleteResult = {
        #ok;
        #scenarioNotFound;
        #notAuthorized;
    };

    public type OnNewScenarioRequest = {
        scenarioId : Text;
        optionCount : Nat;
    };

    public type OnNewScenarioResult = {
        #ok;
        #notAuthorized;
    };

    public type OnSeasonCompleteResult = {
        #ok;
        #notAuthorized;
    };

    public type SetLeagueResult = {
        #ok;
        #notAuthorized;
    };

    public type TeamActorInfo = {};

    public type TeamActorInfoWithId = TeamActorInfo and { id : Principal };

    public type CreateTeamRequest = {

    };

    public type CreateTeamResult = {
        #ok : {
            id : Principal;
        };
    };

    public type MatchVoteResult = {
        votes : [Nat];
    };

    public type ScenarioVoteResult = {
        option : Nat;
    };

    public type GetScenarioVoteRequest = {
        scenarioId : Text;
    };

    public type GetScenarioVoteResult = {
        #ok : ?Nat;
        #scenarioNotFound;
    };

    public type GetWinningScenarioOptionRequest = {
        scenarioId : Text;
    };

    public type GetWinningScenarioOptionResult = {
        #ok : Nat;
        #noVotes;
        #notAuthorized;
        #scenarioNotFound;
    };

    public type GetCyclesResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type VoteOnScenarioRequest = {
        scenarioId : Text;
        option : Nat;
    };

    public type VoteOnScenarioResult = {
        #ok;
        #notAuthorized;
        #scenarioNotFound;
        #votingNotOpen;
        #teamNotInScenario;
        #alreadyVoted;
        #seasonStatusFetchError : Text;
        #invalidOption;
    };
};
