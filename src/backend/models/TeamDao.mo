import FieldPosition "FieldPosition";
import Skill "Skill";
module {
    public type ProposalContent = {
        #changeName : ChangeTeamNameContent;
        #train : TrainContent;
        #swapPlayerPositions : SwapPlayerPositionsContent;
        #changeColor : ChangeTeamColorContent;
        #changeLogo : ChangeTeamLogoContent;
        #changeMotto : ChangeTeamMottoContent;
        #changeDescription : ChangeTeamDescriptionContent;
        #modifyLink : ModifyTeamLinkContent;
    };

    public type ChangeTeamNameContent = {
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

    public type ChangeTeamColorContent = {
        color : (Nat8, Nat8, Nat8);
    };

    public type ChangeTeamLogoContent = {
        logoUrl : Text;
    };

    public type ChangeTeamMottoContent = {
        motto : Text;
    };

    public type ChangeTeamDescriptionContent = {
        description : Text;
    };

    public type ModifyTeamLinkContent = {
        name : Text;
        url : ?Text;
    };
};
