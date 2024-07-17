module {

    public type ProposalContent = {
        #motion : MotionContent;
        #changeTeamName : ChangeTeamNameContent;
        #changeTeamColor : ChangeTeamColorContent;
        #changeTeamLogo : ChangeTeamLogoContent;
        #changeTeamMotto : ChangeTeamMottoContent;
        #changeTeamDescription : ChangeTeamDescriptionContent;
    };

    public type MotionContent = {
        title : Text;
        description : Text;
    };

    public type ChangeTeamNameContent = {
        teamId : Nat;
        name : Text;
    };

    public type ChangeTeamColorContent = {
        teamId : Nat;
        color : (Nat8, Nat8, Nat8);
    };

    public type ChangeTeamLogoContent = {
        teamId : Nat;
        logoUrl : Text;
    };

    public type ChangeTeamMottoContent = {
        teamId : Nat;
        motto : Text;
    };

    public type ChangeTeamDescriptionContent = {
        teamId : Nat;
        description : Text;
    };
};
