import Nat "mo:base/Nat";
import Action "entities/Action";
module {
    public type ActionResult = {
        effects : [CombatEffectResult];
    };

    public type CombatEffectResult = {
        target : ActionTargetResult;
        kind : CombatEffectKindResult;
    };

    public type CombatEffectKindResult = {
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
