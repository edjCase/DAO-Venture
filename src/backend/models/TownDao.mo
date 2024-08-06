import Flag "Flag";
import Town "Town";
module {
    public type ProposalContent = {
        #motion : MotionContent;
        #changeName : ChangeTownNameContent;
        #changeFlag : ChangeTownFlagContent;
        #changeMotto : ChangeTownMottoContent;
        #addJob : AddJobContent;
        #updateJob : UpdateJobContent;
        #removeJob : RemoveJobContent;
        #foundTown : FoundTownContent;
        #claimLocation : ClaimLocationContent;
    };

    public type ClaimLocationContent = {
        locationId : Nat;
        leaveLocationId : ?Nat;
    };

    public type AddJobContent = {
        job : Town.Job;
    };

    public type UpdateJobContent = {
        jobId : Nat;
        job : Town.Job;
    };

    public type RemoveJobContent = {
        jobId : Nat;
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

    public type FoundTownContent = {
        name : Text;
        flag : Flag.FlagImage;
        color : (Nat8, Nat8, Nat8);
        motto : Text;
        migrantIds : [Principal];
        locationId : Nat;
    };
};
