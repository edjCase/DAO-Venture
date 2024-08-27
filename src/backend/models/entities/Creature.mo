import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";

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
    };

    public type CreatureLocationKind = {
        #common;
        #zoneIds : [Text];
    };

    public func validate(
        creature : Creature,
        existingCreaturees : HashMap.HashMap<Text, Creature>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Creature", creature, existingCreaturees, errors);
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
