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
    };

    public type TeamWithId = Team and {
        id : Principal;
    };

    public type TeamWithLedgerId = Team and {
        ledgerId : Principal;
    };
};
