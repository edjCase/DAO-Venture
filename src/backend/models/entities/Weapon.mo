import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Entity "Entity";

module Weapon {

    public type Weapon = Entity.Entity and {
        baseStats : WeaponStats;
        requirements : ?WeaponRequirement;
        // TODO weapon effects like bleed/stun
    };

    public type WeaponStats = {
        damage : WeaponDamage;
        accuracy : Int;
        criticalChance : Nat;
        criticalMultiplier : Nat;
        boosts : [StatBoost];
    };

    public type WeaponDamage = {
        attacks : Nat;
        min : Nat;
        max : Nat;
        // TODO damage kind?
    };

    public type WeaponRequirement = {
        #attack : Int;
        #magic : Int;
        #speed : Int;
        #defense : Int;
    };

    public type StatBoost = {
        kind : StatBoostKind;
        attribute : WeaponAttribute;
    };

    public type StatBoostKind = {
        #addFlat : Nat;
        #addBasePercent : Nat;
        #addStatPercent : (StatKind, Nat);
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

    public func validate(
        weapon : Weapon,
        existingWeapons : HashMap.HashMap<Text, Weapon>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Weapon", weapon, existingWeapons, errors);
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
