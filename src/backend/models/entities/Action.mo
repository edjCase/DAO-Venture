import Nat "mo:base/Nat";
import Entity "Entity";

module {

    public type Action = Entity.Entity and {
        target : ActionTarget;
        effects : [ActionEffect];
    };

    public type ActionEffect = {
        target : ActionEffectTarget;
        kind : ActionEffectKind;
    };

    public type ActionEffectTarget = {
        #self;
        #targets;
    };

    public type ActionEffectKind = {
        #damage : Damage;
        #block : Block;
        #heal : Heal;
        #addStatusEffect : StatusEffect;
    };

    public type ActionTarget = {
        scope : ActionTargetScope;
        selection : ActionTargetSelection;
    };

    public type ActionTargetScope = {
        #ally;
        #enemy;
        #any;
    };

    public type ActionTargetSelection = {
        #random : {
            count : Nat;
        };
        #chosen;
        // #positions : [Position]; // TODO
        #all;
    };

    public type Damage = {
        min : Nat;
        max : Nat;
        timing : ActionTimingKind;
    };

    public type Block = {
        min : Nat;
        max : Nat;
        timing : ActionTimingKind;
    };

    public type Heal = {
        min : Nat;
        max : Nat;
        timing : ActionTimingKind;
    };

    public type ActionTimingKind = {
        #immediate;
        #periodic : PeriodicTiming;
    };

    public type PeriodicTiming = {
        phase : TurnPhase;
        remainingTurns : Nat;
    };

    public type TurnPhase = {
        #start;
        #end;
    };

    public type StatusEffect = {
        kind : StatusEffectKind;
        duration : ?Nat;
    };

    public type StatusEffectKind = {
        #vulnerable;
        #weak;
        #stunned;
        #retaliating : Retaliating;
    };

    public type Retaliating = {
        #flat : Nat;
    };

};
