import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import Weapon "Weapon";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";
import Action "Action";

module {
    public type Creature = Entity.Entity and {
        location : CreatureLocationKind;
        weaponId : Text;
        health : Nat;
        maxHealth : Nat;
        actionIds : [Text];
        kind : CreatureKind;
        unlockRequirement : UnlockRequirement.UnlockRequirement;
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
        actions : HashMap.HashMap<Text, Action.Action>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Creature", creature, errors);

        for (actionId in creature.actionIds.vals()) {
            if (actions.get(actionId) == null) {
                errors.add("Action does not exist: " # actionId);
            };
        };
        switch (UnlockRequirement.validate(creature.unlockRequirement, achievements)) {
            case (#err(err)) errors.append(Buffer.fromArray(err));
            case (#ok) ();
        };
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
