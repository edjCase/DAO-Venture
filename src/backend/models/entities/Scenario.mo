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
        #reward : ScenarioRewardResult;
    };

    public type ScenarioRewardResult = {
        kind : RewardKind;
    };

    public type ScenarioChoiceResult = {
        choiceId : Text;
        kind : ScenarioChoiceResultKind;
    };

    public type ScenarioChoiceResultKind = {
        #startCombat : CombatScenarioState;
        #reward : RewardScenarioState;
        #choice : ChoiceScenarioState;
        #complete;
        #death;
    };

    public type ScenarioCombatResult = {
        log : [CombatLogEntry];
        kind : CombatResultKind;
    };

    public type CombatLogEntry = {
        #damage : DamageLogEntry;
        #heal : HealLogEntry;
        #block : BlockLogEntry;
        #statusEffect : StatusEffectLogEntry;
    };

    public type DamageLogEntry = {
        source : TargetKind;
        target : TargetKind;
        amount : Nat;
    };

    public type HealLogEntry = {
        source : TargetKind;
        target : TargetKind;
        amount : Nat;
    };

    public type BlockLogEntry = {
        source : TargetKind;
        target : TargetKind;
        amount : Nat;
    };

    public type StatusEffectLogEntry = {
        source : TargetKind;
        target : TargetKind;
        statusEffect : ActionResult.StatusEffectResult;
    };

    public type TargetKind = {
        #character;
        #creature : Nat;
        #periodicEffect;
    };

    public type CombatResultKind = {
        #victory : CombatVictoryResult;
        #defeat : CombatDefeatResult;
        #inProgress : CombatScenarioState;
    };

    public type CombatVictoryResult = {
        characterHealth : Nat;
    };

    public type CombatDefeatResult = {
        creatures : [CreatureCombatState];
    };

    public type ScenarioStateKind = {
        #choice : ChoiceScenarioState;
        #combat : CombatScenarioState;
        #reward : RewardScenarioState;
        #complete;
    };

    public type ChoiceScenarioState = {
        choiceIds : [Text];
    };

    public type CombatScenarioState = {
        character : CharacterCombatState;
        creatures : [CreatureCombatState];
    };

    public type RewardScenarioState = {
        options : [RewardKind];
    };

    public type RewardKind = {
        #item : Text;
        #gold : Nat;
        #weapon : Text;
        #health : Nat;
    };

    public type CharacterCombatState = {
        health : Nat;
        maxHealth : Nat;
        block : Nat;
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
        #addItem : AddItemOutcomeEffect;
        #removeItem : Text;
        #swapWeapon : SwapWeaponOutcomeEffect;
    };

    public type AddItemOutcomeEffect = {
        itemId : Text;
        removedItemId : ?Text;
    };

    public type SwapWeaponOutcomeEffect = {
        weaponId : Text;
        removedWeaponId : Text;
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
