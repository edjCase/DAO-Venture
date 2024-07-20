module {
    public type ProposalContent = {
        #motion : MotionContent;
        #changeName : ChangeTownNameContent;
        #changeFlag : ChangeTownFlagContent;
        #changeMotto : ChangeTownMottoContent;
        #addLink : AddTownLinkContent;
        #updateLink : UpdateTownLinkContent;
        #removeLink : RemoveTownLinkContent;
    };

    public type MotionContent = {
        title : Text;
        description : Text;
    };

    public type ChangeTownNameContent = {
        name : Text;
    };

    public type ChangeTownFlagContent = {
        format : { #jpg; #png; #webp };
        data : Blob;
    };

    public type ChangeTownMottoContent = {
        motto : Text;
    };

    public type AddTownLinkContent = {
        name : Text;
        url : Text;
    };

    public type UpdateTownLinkContent = {
        name : Text;
        url : Text;
    };

    public type RemoveTownLinkContent = {
        name : Text;
    };
};
