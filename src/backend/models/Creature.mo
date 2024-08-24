import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import TextX "mo:xtended-text/TextX";
import Weapon "Weapon";

module {
    public type Creature = {
        id : Text;
        name : Text;
        description : Text;
        location : CreatureLocationKind;
        weapon : Weapon.Weapon;
        health : Nat;
        stats : CreatureStats;
    };

    public type CreatureLocationKind = {
        #common;
        #zoneIds : [Text];
    };

    public type CreatureStats = {
        attack : Int;
        defense : Int;
        magic : Int;
        speed : Int;
    };

    public func validate(
        creature : Creature,
        existingCreaturees : HashMap.HashMap<Text, Creature>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(creature.id)) {
            errors.add("Creature id cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(creature.name)) {
            errors.add("Creature name cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(creature.description)) {
            errors.add("Creature description cannot be empty.");
        };
        if (existingCreaturees.get(creature.id) != null) {
            errors.add("Creature id " # creature.id # " already exists.");
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
