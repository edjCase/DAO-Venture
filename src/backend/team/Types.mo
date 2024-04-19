import Principal "mo:base/Principal";
import Dao "../Dao";
import Skill "../models/Skill";
import CommonTypes "../Types";
import FieldPosition "../models/FieldPosition";
import Team "../models/Team";
module {

    public type Actor = actor {
        setLeague : (id : Principal) -> async SetLeagueResult;
        getTeams : query () -> async [Team.Team];
        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;
        createProposal : (teamId : Nat, request : CreateProposalRequest) -> async CreateProposalResult;
        getProposal : query (teamId : Nat, id : Nat) -> async GetProposalResult;
        getProposals : query (teamId : Nat, count : Nat, offset : Nat) -> async GetProposalsResult;
        voteOnProposal : (teamId : Nat, request : VoteOnProposalRequest) -> async VoteOnProposalResult;
        getScenarioVotingResults : (request : GetScenarioVotingResultsRequest) -> async GetScenarioVotingResultsResult;
        onScenarioStart : (request : OnScenarioStartRequest) -> async OnScenarioStartResult;
        onScenarioEnd : (request : OnScenarioEndRequest) -> async OnScenarioEndResult;
        onSeasonEnd() : async OnSeasonEndResult;
        getLinks : query () -> async GetLinksResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        updateTeamEnergy : (teamId : Nat, delta : Int) -> async UpdateTeamEnergyResult;
        updateTeamEntropy : (teamId : Nat, delta : Int) -> async UpdateTeamEntropyResult;
        updateTeamMotto : (teamId : Nat, motto : Text) -> async UpdateTeamMottoResult;
        updateTeamDescription : (teamId : Nat, description : Text) -> async UpdateTeamDescriptionResult;
        updateTeamLogo : (teamId : Nat, logoUrl : Text) -> async UpdateTeamLogoResult;
        updateTeamColor : (teamId : Nat, color : (Nat8, Nat8, Nat8)) -> async UpdateTeamColorResult;
        updateTeamName : (teamId : Nat, name : Text) -> async UpdateTeamNameResult;
    };

    public type UpdateTeamEnergyResult = {
        #ok;
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamEntropyResult = {
        #ok;
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamMottoResult = {
        #ok;
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamDescriptionResult = {
        #ok;
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamLogoResult = {
        #ok;
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamColorResult = {
        #ok;
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamNameResult = {
        #ok;
        #nameTaken;
        #notAuthorized;
        #teamNotFound;
    };

    public type Link = {
        name : Text;
        url : Text;
    };

    public type GetLinksResult = {
        #ok : [TeamLinks];
    };

    public type TeamLinks = {
        teamId : Nat;
        links : [Link];
    };

    public type GetProposalResult = {
        #ok : Proposal;
        #proposalNotFound;
        #teamNotFound;
    };

    public type GetProposalsResult = {
        #ok : CommonTypes.PagedResult<Proposal>;
        #teamNotFound;
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
        #teamNotFound;
    };

    public type Proposal = Dao.Proposal<ProposalContent>;

    public type ProposalContent = {
        #changeName : ChangeNameContent;
        #train : TrainContent;
        #swapPlayerPositions : SwapPlayerPositionsContent;
        #changeColor : ChangeColorContent;
        #changeLogo : ChangeLogoContent;
        #changeMotto : ChangeMottoContent;
        #changeDescription : ChangeDescriptionContent;
        #modifyLink : ModifyLinkContent;
    };

    public type ChangeNameContent = {
        name : Text;
    };

    public type TrainContent = {
        position : FieldPosition.FieldPosition;
        skill : Skill.Skill;
    };

    public type SwapPlayerPositionsContent = {
        position1 : FieldPosition.FieldPosition;
        position2 : FieldPosition.FieldPosition;
    };

    public type ChangeColorContent = {
        color : (Nat8, Nat8, Nat8);
    };

    public type ChangeLogoContent = {
        logoUrl : Text;
    };

    public type ChangeMottoContent = {
        motto : Text;
    };

    public type ChangeDescriptionContent = {
        description : Text;
    };

    public type ModifyLinkContent = {
        name : Text;
        url : ?Text;
    };

    public type CreateProposalRequest = {
        content : ProposalContent;
    };

    public type CreateProposalResult = {
        #ok : Nat;
        #notAuthorized;
        #teamNotFound;
    };

    public type OnScenarioEndRequest = {
        scenarioId : Nat;
        energyDividends : [EnergyDividend];
    };

    public type EnergyDividend = {
        teamId : Nat;
        energy : Nat;
    };

    public type OnScenarioEndResult = {
        #ok;
        #scenarioNotFound;
        #notAuthorized;
    };

    public type OnScenarioStartRequest = {
        scenarioId : Nat;
        optionCount : Nat;
    };

    public type OnScenarioStartResult = {
        #ok;
        #notAuthorized;
    };

    public type OnSeasonEndResult = {
        #ok;
        #notAuthorized;
    };

    public type SetLeagueResult = {
        #ok;
        #notAuthorized;
    };

    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        color : (Nat8, Nat8, Nat8);
    };

    public type CreateTeamResult = {
        #ok : Nat;
        #nameTaken;
        #notAuthorized;
    };

    public type MatchVoteResult = {
        votes : [Nat];
    };

    public type ScenarioVoteResult = {
        option : Nat;
    };

    public type GetScenarioVoteRequest = {
        scenarioId : Nat;
    };

    public type ScenarioVote = {
        option : ?Nat;
        votingPower : Nat;
    };

    public type GetScenarioVoteResult = {
        #ok : ScenarioVote;
        #scenarioNotFound;
        #notEligible;
    };

    public type GetScenarioVotingResultsRequest = {
        scenarioId : Nat;
    };

    public type ScenarioTeamVotingResult = {
        teamId : Nat;
        option : Nat;
    };

    public type ScenarioVotingResults = {
        teamOptions : [ScenarioTeamVotingResult];
    };

    public type GetScenarioVotingResultsResult = {
        #ok : ScenarioVotingResults;
        #notAuthorized;
        #scenarioNotFound;
    };

    public type GetCyclesResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type VoteOnScenarioRequest = {
        scenarioId : Nat;
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
        #teamNotFound;
    };
};
