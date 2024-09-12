import Nat "mo:base/Nat";
import Action "entities/Action";
module {
    public type ActionResult = {
        effects : [ActionEffectResult];
    };

    public type ActionEffectResult = {
        target : ActionTargetResult;
        kind : ActionEffectKindResult;
    };

    public type ActionEffectKindResult = {
        #damage : Nat;
        #block : Nat;
        #heal : Nat;
        #addStatusEffect : StatusEffectResult;
    };

    public type ActionTargetResult = {
        #creature : Nat;
        #character;
    };

    public type StatusEffectResultKind = Action.StatusEffectKind or {
        #periodic : PeriodicEffectResult;
    };

    public type PeriodicEffectResult = {
        kind : PeriodicEffectKind;
        amount : Nat;
        phase : Action.TurnPhase;
    };

    public type PeriodicEffectKind = {
        #damage;
        #heal;
        #block;
    };

    public type StatusEffectResult = {
        kind : StatusEffectResultKind;
        remainingTurns : Nat;
    };
};
