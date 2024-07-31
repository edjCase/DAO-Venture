import Flag "Flag";
import Time "mo:base/Time";
import World "World";

module {

    public type Town = {
        id : Nat;
        name : Text;
        genesisTime : Time.Time;
        motto : Text;
        flagImage : Flag.FlagImage;
        entropy : Nat;
        size : Nat;
        population : Nat;
        populationMax : Nat;
        health : Nat;
        upkeepCondition : Nat;
        jobs : [Job];
        skills : SkillList;
        resources : ResourceList;
    };

    public type ResourceList = {
        gold : Nat;
        wood : Nat;
        food : Nat;
        stone : Nat;
    };

    public type SkillKind = {
        #woodCutting;
        #farming;
        #mining;
    };

    public type SkillList = {
        woodCutting : Skill;
        farming : Skill;
        mining : Skill;
        carpentry : Skill;
        masonry : Skill;
    };

    public type Skill = {
        techLevel : Nat;
        proficiencyLevel : Nat;
    };

    public type Job = {
        #gatherResource : GatherResourceJob;
        #processResource : ProcessResourceJob;
        #explore : ExploreJob;
    };

    public type GatherResourceJob = {
        locationId : Nat;
        resource : World.ResourceKind;
        workerQuota : Nat;
    };

    public type ProcessResourceJob = {
        resource : ProcessingResourceKind;
        workerQuota : Nat;
    };

    public type ProcessingResourceKind = {
        #wood;
        #stone;
    };

    public type ExploreJob = {
        locationId : Nat;
        workerQuota : Nat;
    };
};
