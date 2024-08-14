import Nat "mo:base/Nat";
import MysteriousStructure "../scenarios/MysteriousStructure";
import Outcome "Outcome";

module {

    public type Scenario = {
        id : Nat;
        kind : ScenarioKind;
        outcome : ?Outcome.Outcome;
    };

    public type ScenarioKind = {
        #mysteriousStructure : MysteriousStructure.Data;
    };

};
