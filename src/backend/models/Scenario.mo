import Nat "mo:base/Nat";
import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import ActionResult "./ActionResult";
import ScenarioMetaData "./entities/ScenarioMetaData";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Scenario = {
        metaDataId : Text;
        previousStages : [ScenarioStageResult];
        currentStage : ScenarioStageKind;
    };

    public type CompletedScenario = {
        metaDataId : Text;
        stages : [ScenarioStageResult];
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
        kind : ScenarioMetaData.RewardKind;
    };

    public type ScenarioChoiceResult = {
        choice : ScenarioMetaData.Choice;
        kind : ChoiceResultKind;
    };

    public type ChoiceResultKind = {
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

    public type CombatScenarioKind = {
        #normal;
        #elite;
        #boss;
    };

    public type ScenarioStageKind = {
        #choice : ChoiceScenarioState;
        #combat : CombatScenarioState;
        #reward : RewardScenarioState;
    };

    public type ChoiceScenarioState = {
        choices : [ScenarioMetaData.Choice];
    };

    public type CombatScenarioState = {
        character : CharacterCombatState;
        creatures : [CreatureCombatState];
        nextPath : ScenarioMetaData.NextPathKind;
    };

    public type RewardScenarioState = {
        options : (ScenarioMetaData.RewardKind, ScenarioMetaData.RewardKind, ScenarioMetaData.RewardKind);
        nextPath : ScenarioMetaData.NextPathKind;
    };

    public type CommonCombatState = {
        health : Nat;
        maxHealth : Nat;
        block : Nat;
        statusEffects : [ActionResult.StatusEffectResult];
    };

    public type CharacterCombatState = CommonCombatState and {
        skillActionId : ?Text;
        itemActionId : ?Text;
        weaponActionId : ?Text;
    };

    public type CreatureCombatState = CommonCombatState and {
        health : Nat;
        maxHealth : Nat;
        creatureId : Text;
        actionIds : [Text];
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

};
