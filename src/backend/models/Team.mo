import Trait "Trait";
module {

    public type TeamId = {
        #team1;
        #team2;
    };

    public type TeamIdOrBoth = TeamId or { #bothTeams };

    public type TeamIdOrTie = TeamId or { #tie };

    public type Team = {
        id : Nat;
        name : Text;
        logoUrl : Text;
        motto : Text;
        description : Text;
        entropy : Nat;
        energy : Int;
        color : (Nat8, Nat8, Nat8);
        traits : [Trait.Trait];
        links : [Link];
    };

    public type Link = {
        name : Text;
        url : Text;
    };
};
