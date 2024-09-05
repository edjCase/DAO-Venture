import Nat "mo:base/Nat";
import Action "entities/Action";
module {
    public type ActionResult = {
        effects : [ActionEffectResult];
    };

    public type ActionEffectResult = {
        targets : [ActionTargetResult];
        kind : ActionEffectKindResult;
    };

    public type ActionEffectKindResult = {
        #damage : DamageResult;
        #block : BlockResult;
        #heal : HealResult;
        #addStatusEffect : StatusEffectResult;
    };

    public type ActionTargetResult = {
        #creature : Nat;
        #character;
    };

    type GenericCastResult = {
        amount : Nat;
        delay : ?CastDelay;
    };

    public type CastDelay = {
        turns : Nat;
        kind : Action.PeriodicTiming;
    };

    public type DamageResult = GenericCastResult;

    public type BlockResult = GenericCastResult;

    public type HealResult = GenericCastResult;

    public type StatusEffectResult = {
        kind : Action.StatusEffectKind;
        remainingTurns : Nat;
    };
};
