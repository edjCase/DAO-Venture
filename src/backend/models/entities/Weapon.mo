import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Entity "Entity";

module Weapon {

    public type Weapon = Entity.Entity and {
        baseStats : WeaponStats;
        requirements : [WeaponRequirement];
        // TODO weapon effects like bleed/stun
    };

    public type WeaponStats = {
        attacks : Nat;
        minDamage : Nat;
        maxDamage : Nat;
        accuracy : Int;
        criticalChance : Nat;
        criticalMultiplier : Nat;
        statModifiers : [StatModifier];
    };

    public type WeaponRequirement = {
        #attack : Int;
        #magic : Int;
        #speed : Int;
        #defense : Int;
        #maxHealth : Nat;
    };

    public type StatModifier = {
        characterStat : CharacterStatKind;
        attribute : WeaponAttribute;
        factor : Float;
    };

    public type CharacterStatKind = {
        #attack;
        #magic;
        #speed;
        #defense;
        #health : {
            inverse : Bool;
        };
        #gold;
    };

    public type WeaponAttribute = {
        #attacks;
        #damage;
        #minDamage;
        #maxDamage;
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
