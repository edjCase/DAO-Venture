import Flag "Flag";
import Time "mo:base/Time";

module {

    public type Town = {
        id : Nat;
        name : Text;
        genesisTime : Time.Time;
        motto : Text;
        flagImage : Flag.FlagImage;
        color : (Nat8, Nat8, Nat8);
        size : Nat;
        population : Nat;
        populationMax : Nat;
        health : Nat;
        upkeepCondition : Nat;
        jobs : [Job];
        resources : ResourceList;
    };

    public type ResourceList = {
        gold : Nat;
        wood : Nat;
        food : Nat;
        stone : Nat;
    };

    public type Job = {
        #explore : ExploreJob;
    };

    public type ExploreJob = {
        locationId : Nat;
    };
};
