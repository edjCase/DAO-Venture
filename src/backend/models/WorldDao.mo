module {

    public type ProposalContent = {
        #motion : MotionContent;
        #changeTownName : ChangeTownNameContent;
        #changeTownColor : ChangeTownColorContent;
        #changeTownLogo : ChangeTownLogoContent;
        #changeTownMotto : ChangeTownMottoContent;
        #changeTownDescription : ChangeTownDescriptionContent;
    };

    public type MotionContent = {
        title : Text;
        description : Text;
    };

    public type ChangeTownNameContent = {
        townId : Nat;
        name : Text;
    };

    public type ChangeTownColorContent = {
        townId : Nat;
        color : (Nat8, Nat8, Nat8);
    };

    public type ChangeTownLogoContent = {
        townId : Nat;
        logoUrl : Text;
    };

    public type ChangeTownMottoContent = {
        townId : Nat;
        motto : Text;
    };

    public type ChangeTownDescriptionContent = {
        townId : Nat;
        description : Text;
    };
};
