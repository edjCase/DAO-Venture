import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import Weapon "Weapon";

module {
    public type Creature = Entity.Entity and {
        location : CreatureLocationKind;
        weaponId : Text;
        health : Nat;
        maxHealth : Nat;
        attack : Int;
        defense : Int;
        magic : Int;
        speed : Int;
        kind : CreatureKind;
    };

    public type CreatureKind = {
        #normal;
        #elite;
        #boss;
    };

    public type CreatureLocationKind = {
        #common;
        #zoneIds : [Text];
    };

    public func validate(
        creature : Creature,
        existingCreatures : HashMap.HashMap<Text, Creature>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Creature", creature, existingCreatures, errors);
        // check health is above 0
        if (creature.health < 1) {
            errors.add("Health must be above 0");
        };
        // check maxHealth is above 0
        if (creature.maxHealth < 1) {
            errors.add("Max health must be above 0");
        };
        if (weapons.get(creature.weaponId) == null) {
            errors.add("Weapon does not exist: " # creature.weaponId);
        };
        switch (creature.location) {
            case (#common) ();
            case (#zoneIds(zoneIds)) {
                if (zoneIds.size() < 1) {
                    errors.add("ZoneIds must have at least one element");
                };
            };
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
