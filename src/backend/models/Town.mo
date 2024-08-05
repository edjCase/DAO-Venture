import Flag "Flag";
import Time "mo:base/Time";

module {

    public type Town = {
        id : Nat;
        name : Text;
        genesisTime : Time.Time;
        motto : Text;
        flagImage : Flag.FlagImage;
        size : Nat;
        population : Nat;
        populationMax : Nat;
        health : Nat;
        upkeepCondition : Nat;
        jobs : [Job];
        skills : SkillList;
        resources : ResourceList;
        workPlan : TownWorkPlan;
    };

    public type TownWorkPlan = {
        gatherWood : DeterminateGatheringWorkPlan;
        gatherFood : DeterminateGatheringWorkPlan;
        gatherStone : EfficiencyGatheringWorkPlan;
        gatherGold : EfficiencyGatheringWorkPlan;
        processWood : ProcessResourceWorkPlan;
        processStone : ProcessResourceWorkPlan;
    };

    public type ProcessResourceWorkPlan = {
        weight : Float;
        maxStorage : Nat;
    };

    public type DeterminateGatheringWorkPlan = {
        weight : Float;
    };

    public type EfficiencyGatheringWorkPlan = {
        weight : Float;
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
        #explore : ExploreJob;
    };

    public type ExploreJob = {
        locationId : Nat;
    };
};
