import Principal "mo:base/Principal";
import Dao "../Dao";
import Skill "../models/Skill";
import CommonTypes "../Types";
import FieldPosition "../models/FieldPosition";
import Team "../models/Team";
import Result "mo:base/Result";
import Season "../models/Season";

module {

    public type Actor = actor {
        setLeague : (id : Principal) -> async SetLeagueResult;
        getTeams : query () -> async [Team.Team];
        createProposal : (teamId : Nat, request : CreateProposalRequest) -> async CreateProposalResult;
        getProposal : query (teamId : Nat, id : Nat) -> async GetProposalResult;
        getProposals : query (teamId : Nat, count : Nat, offset : Nat) -> async GetProposalsResult;
        voteOnProposal : (teamId : Nat, request : VoteOnProposalRequest) -> async VoteOnProposalResult;
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async Result.Result<(), OnMatchGroupCompleteError>;
        onSeasonEnd() : async OnSeasonEndResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        updateTeamEnergy : (teamId : Nat, delta : Int) -> async UpdateTeamEnergyResult;
        updateTeamEntropy : (teamId : Nat, delta : Int) -> async UpdateTeamEntropyResult;
        updateTeamMotto : (teamId : Nat, motto : Text) -> async UpdateTeamMottoResult;
        updateTeamDescription : (teamId : Nat, description : Text) -> async UpdateTeamDescriptionResult;
        updateTeamLogo : (teamId : Nat, logoUrl : Text) -> async UpdateTeamLogoResult;
        updateTeamColor : (teamId : Nat, color : (Nat8, Nat8, Nat8)) -> async UpdateTeamColorResult;
        updateTeamName : (teamId : Nat, name : Text) -> async UpdateTeamNameResult;
        createTeamTrait : (request : CreateTeamTraitRequest) -> async CreateTeamTraitResult;
        addTraitToTeam : (teamId : Nat, traitId : Text) -> async AddTraitToTeamResult;
        removeTraitFromTeam : (teamId : Nat, traitId : Text) -> async RemoveTraitFromTeamResult;
    };

    public type CreateTeamTraitRequest = {
        id : Text;
        name : Text;
        description : Text;
    };

    public type CreateTeamTraitError = {
        #notAuthorized;
        #idTaken;
        #invalid : [Text];
    };

    public type CreateTeamTraitResult = Result.Result<(), CreateTeamTraitError>;

    public type AddTraitToTeamOk = {
        hadTrait : Bool;
    };

    public type AddTraitToTeamError = {
        #notAuthorized;
        #teamNotFound;
        #traitNotFound;
    };

    public type AddTraitToTeamResult = Result.Result<AddTraitToTeamOk, AddTraitToTeamError>;

    public type RemoveTraitFromTeamOk = {
        hadTrait : Bool;
    };

    public type RemoveTraitFromTeamError = {
        #notAuthorized;
        #teamNotFound;
        #traitNotFound;
    };

    public type RemoveTraitFromTeamResult = Result.Result<RemoveTraitFromTeamOk, RemoveTraitFromTeamError>;

    public type OnMatchGroupCompleteRequest = {
        matchGroup : Season.CompletedMatchGroup;
    };

    public type OnMatchGroupCompleteError = {
        #notAuthorized;
    };

    public type UpdateTeamEnergyResult = Result.Result<(), UpdateTeamEnergyError>;

    public type UpdateTeamEnergyError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamEntropyResult = Result.Result<(), UpdateTeamEntropyError>;

    public type UpdateTeamEntropyError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamMottoResult = Result.Result<(), UpdateTeamMottoError>;

    public type UpdateTeamMottoError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamDescriptionResult = Result.Result<(), UpdateTeamDescriptionError>;

    public type UpdateTeamDescriptionError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamLogoResult = Result.Result<(), UpdateTeamLogoError>;

    public type UpdateTeamLogoError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamColorResult = Result.Result<(), UpdateTeamColorError>;

    public type UpdateTeamColorError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type UpdateTeamNameResult = Result.Result<(), UpdateTeamNameError>;

    public type UpdateTeamNameError = {
        #nameTaken;
        #notAuthorized;
        #teamNotFound;
    };

    public type Link = {
        name : Text;
        url : Text;
    };

    public type TeamLinks = {
        teamId : Nat;
        links : [Link];
    };

    public type GetProposalResult = Result.Result<Proposal, GetProposalError>;

    public type GetProposalError = {
        #proposalNotFound;
        #teamNotFound;
    };

    public type GetProposalsResult = Result.Result<CommonTypes.PagedResult<Proposal>, GetProposalsError>;

    public type GetProposalsError = {
        #teamNotFound;
    };

    public type VoteOnProposalRequest = {
        proposalId : Nat;
        vote : Bool;
    };

    public type VoteOnProposalResult = Result.Result<(), VoteOnProposalError>;

    public type VoteOnProposalError = {
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

    public type CreateProposalResult = Result.Result<Nat, CreateProposalError>;

    public type CreateProposalError = {
        #notAuthorized;
        #teamNotFound;
    };

    public type OnSeasonEndResult = Result.Result<(), OnSeasonEndError>;

    public type OnSeasonEndError = {
        #notAuthorized;
    };

    public type SetLeagueResult = Result.Result<(), SetLeagueError>;

    public type SetLeagueError = {
        #notAuthorized;
    };

    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        color : (Nat8, Nat8, Nat8);
    };

    public type CreateTeamResult = Result.Result<Nat, CreateTeamError>;

    public type CreateTeamError = {
        #nameTaken;
        #notAuthorized;
    };

    public type MatchVoteResult = {
        votes : [Nat];
    };

    public type GetCyclesResult = Result.Result<Nat, GetCyclesError>;

    public type GetCyclesError = {
        #notAuthorized;
    };
};
