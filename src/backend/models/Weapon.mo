import Text "mo:base/Text";

module Weapon {

    public type Weapon = {
        id : Text;
        name : Text;
        description : Text;
        baseStats : WeaponStats;
        requirements : ?WeaponRequirement;
        // TODO weapon effects like bleed/stun
    };

    public type WeaponStats = {
        damage : WeaponDamage;
        accuracy : Int;
        criticalChance : Nat;
        criticalMultiplier : Float;
        boosts : [StatBoost];
    };

    public type WeaponDamage = {
        attacks : Nat;
        min : Nat;
        max : Nat;
        // TODO damage kind?
    };

    public type WeaponRequirement = {
        #attack : Nat;
        #magic : Nat;
        #speed : Nat;
        #defense : Nat;
    };

    public type StatBoost = {
        stat : StatKind;
        boostType : BoostType;
        affectedAttribute : WeaponAttribute;
    };

    public type BoostType = {
        #addFlat : Nat;
        #addPercent : Float;
    };

    public type StatKind = {
        #attack;
        #magic;
        #speed;
        #defense;
    };

    public type WeaponAttribute = {
        #damage;
        #accuracy;
        #criticalChance;
        #criticalMultiplier;
    };
};
