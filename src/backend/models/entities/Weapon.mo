import Text "mo:base/Text";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";

module Weapon {

    public type Weapon = Entity.Entity and {
        baseStats : WeaponStats;
        requirements : [WeaponRequirement];
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
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
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Weapon", weapon, errors);
        switch (weapon.unlockRequirement) {
            case (null) ();
            case (?unlockRequirement) {
                switch (UnlockRequirement.validate(unlockRequirement, achievements)) {
                    case (#err(err)) errors.append(Buffer.fromArray(err));
                    case (#ok) ();
                };
            };
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
