module {

    public type ProposalContent = {
        #motion : MotionContent;
    };

    public type MotionContent = {
        title : Text;
        description : Text;
    };
};
