import Flag "Flag";
module {
    public type ProposalContent = {
        #motion : MotionContent;
        #changeName : ChangeTownNameContent;
        #changeFlag : ChangeTownFlagContent;
        #changeMotto : ChangeTownMottoContent;
    };

    public type MotionContent = {
        title : Text;
        description : Text;
    };

    public type ChangeTownNameContent = {
        name : Text;
    };

    public type ChangeTownFlagContent = {
        image : Flag.FlagImage;
    };

    public type ChangeTownMottoContent = {
        motto : Text;
    };
};
