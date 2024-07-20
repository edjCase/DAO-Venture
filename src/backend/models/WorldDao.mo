import Flag "Flag";
module {

    public type ProposalContent = {
        #motion : MotionContent;
        #changeTownName : ChangeTownNameContent;
        #changeTownFlag : ChangeTownFlagContent;
        #changeTownMotto : ChangeTownMottoContent;
    };

    public type MotionContent = {
        title : Text;
        description : Text;
    };

    public type ChangeTownNameContent = {
        townId : Nat;
        name : Text;
    };

    public type ChangeTownFlagContent = {
        townId : Nat;
        flagImage : Flag.FlagImage;
    };

    public type ChangeTownMottoContent = {
        townId : Nat;
        motto : Text;
    };
};
