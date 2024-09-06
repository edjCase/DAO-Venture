import Nat "mo:base/Nat";
import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import ActionResult "../ActionResult";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Scenario = {
        id : Nat;
        metaDataId : Text;
        data : [GeneratedDataFieldInstance];
        previousStages : [ScenarioStageResult];
        state : ScenarioStateKind;
    };

    public type ScenarioStageResult = {
        effects : [OutcomeEffect];
        kind : ScenarioStageResultKind;
    };
    public type ScenarioStageResultKind = {
        #choice : ScenarioChoiceResult;
        #combat : ScenarioCombatResult;
    };

    public type ScenarioChoiceResult = {
        choiceId : Text;
        kind : ScenarioChoiceResultKind;
    };

    public type ScenarioChoiceResultKind = {
        #startCombat : CombatScenarioState;
        #choice : ChoiceScenarioState;
        #complete;
        #death;
    };

    public type ScenarioCombatResult = {
        #victory;
        #defeat : CombatDefeatResult;
        #inProgress : CombatScenarioState;
    };

    public type CombatDefeatResult = {
        creatures : [CreatureCombatState];
    };

    public type ScenarioStateKind = {
        #choice : ChoiceScenarioState;
        #combat : CombatScenarioState;
        #complete;
    };

    public type ChoiceScenarioState = {
        choiceIds : [Text];
    };

    public type CombatScenarioState = {
        character : CharacterCombatState;
        creatures : [CreatureCombatState];
    };

    public type CharacterCombatState = {
        health : Nat;
        maxHealth : Nat;
        shield : Nat;
        statusEffects : [ActionResult.StatusEffectResult];
        availableActionIds : [Text];
    };

    public type CreatureCombatState = CharacterCombatState and {
        health : Nat;
        maxHealth : Nat;
        creatureId : Text;
    };

    public type OutcomeEffect = {
        #text : Text;
        #healthDelta : Int;
        #maxHealthDelta : Int;
        #goldDelta : Int;
        #addItem : Text;
        #removeItem : Text;
    };

    public type CombatTurn = {
        #action : Text;
        #nothing;
    };

    public type AttackerKind = {
        #character;
        #creature;
    };

    public type AttackResult = {
        #hit : HitResult;
        #miss;
    };

    public type HitResult = {
        damage : Nat;
    };

    public type GeneratedDataFieldInstance = {
        id : Text;
        value : GeneratedDataFieldInstanceValue;
    };

    public type GeneratedDataFieldInstanceValue = {
        #nat : Nat;
        #text : Text;
    };

};
