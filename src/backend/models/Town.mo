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

    public type SkillList = {
        woodCutting : Skill;
        farming : Skill;
        mining : Skill;
    };

    public type Skill = {
        techLevel : Nat;
        proficiencyLevel : Nat;
    };

    public type Job = {
        #gatherResource : {
            locationId : Nat;
            resource : World.ResourceKind;
            workerCount : Nat;
        };
        #processResource : {
            resource : World.ResourceKind;
            workerCount : Nat;
        };
    };
};
