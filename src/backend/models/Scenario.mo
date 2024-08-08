import Nat "mo:base/Nat";
import World "World";

module {

    public type Scenario = {
        id : Nat;
        kind : ScenarioKind;
    };

    public type ScenarioKind = {

    };

    public type ResourceCost = {
        kind : World.ResourceKind;
        amount : Nat;
    };
};
