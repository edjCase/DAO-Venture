import Nat "mo:base/Nat";
import Entity "Entity";

module {

    public type Card = Entity.Entity and {
        effects : [Effect];
    };

    public type Effect = {
        target : Target;
        kind : EffectKind;
    };

    public type EffectKind = {
        #damage : Damage;
        #block : Block;
        #heal : Heal;
        #addStatusEffect : StatusEffect;
    };

    public type Target = {
        scope : TargetScope;
        selection : TargetSelection;
    };

    public type TargetScope = {
        #ally;
        #enemy;
        #any;
    };

    public type TargetSelection = {
        #random : {
            count : Nat;
        };
        #chosen : {
            count : Nat;
        };
        #positions : [Position];
        #all;
    };

    public type Position = {
        #top;
        #center;
        #bottom;
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
        #overTime : {
            kind : { #startOfTurn; #endOfTurn };
            turns : Nat;
        };
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
