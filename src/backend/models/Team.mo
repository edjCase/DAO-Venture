module {

    public type TeamId = {
        #team1;
        #team2;
    };

    public type TeamIdOrBoth = TeamId or { #bothTeams };

    public type TeamIdOrTie = TeamId or { #tie };

    public type Team = {
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        color : (Nat8, Nat8, Nat8);
    };

    public type TeamWithId = Team and {
        id : Nat;
    };
};
