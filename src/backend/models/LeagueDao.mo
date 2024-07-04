module {

    public type ProposalContent = {
        #changeTeamName : {
            teamId : Nat;
            name : Text;
        };
        #changeTeamColor : {
            teamId : Nat;
            color : (Nat8, Nat8, Nat8);
        };
        #changeTeamLogo : {
            teamId : Nat;
            logoUrl : Text;
        };
        #changeTeamMotto : {
            teamId : Nat;
            motto : Text;
        };
        #changeTeamDescription : {
            teamId : Nat;
            description : Text;
        };
    };
};
