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
        #updateWorkPlan : UpdateWorkPlanContent;
    };

    public type UpdateWorkPlanContent = {
        workPlan : Town.TownWorkPlan;
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
        motto : Text;
        users : [Principal];
        locationId : Nat;
    };
};
