import Skill "Skill";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Trait "Trait";
import MatchAura "MatchAura";

module {
    public type Effect = {
        #skill : {
            target : {
                #team : Principal;
                #player : Nat32;
            };
            skill : Skill.Skill;
            value : Int;
            permanent : Bool;
        };
        #trait : {
            target : {
                #team : Principal;
                #player : Nat32;
            };
            trait : Trait.Trait;
            permanent : Bool;
        };
        #aura : {
            matchGroup : Nat;
            match : Nat;
            aura : MatchAura.MatchAura;
        };
        #points : Int;
    };

    public type ScenarioOption = {
        name : Text;
        description : Text;
        entropy : Int;
        effects : [Effect];
    };

    public type Scenario = {
        id : Nat32;
        name : Text;
        description : Text;
        options : [ScenarioOption];
    };

    public type ScenarioWithChoice = Scenario and {
        choice : Nat;
    };

    public func hash(scenario : Scenario) : Nat32 = scenario.id;

    public func equal(a : Scenario, b : Scenario) : Bool = a.id == b.id;

};
