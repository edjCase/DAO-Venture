import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Item "Item";
import Trait "Trait";
module {

    public type CharacterModifier = {
        #attack : Int;
        #defense : Int;
        #speed : Int;
        #magic : Int;
        #gold : Nat;
        #health : Int;
        #item : Text;
        #trait : Text;
    };

    public func validate(
        modifier : CharacterModifier,
        items : HashMap.HashMap<Text, Item.Item>,
        traits : HashMap.HashMap<Text, Trait.Trait>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        switch (modifier) {
            case (#attack(attack)) {
                if (attack == 0) {
                    errors.add("Attack modifier cannot be 0.");
                };
            };
            case (#defense(defense)) {
                if (defense == 0) {
                    errors.add("Defense modifier cannot be 0.");
                };
            };
            case (#speed(speed)) {
                if (speed == 0) {
                    errors.add("Speed modifier cannot be 0.");
                };
            };
            case (#magic(magic)) {
                if (magic == 0) {
                    errors.add("Magic modifier cannot be 0.");
                };
            };
            case (#gold(gold)) {
                if (gold == 0) {
                    errors.add("Gold modifier cannot be 0.");
                };
            };
            case (#health(health)) {
                if (health == 0) {
                    errors.add("Health modifier cannot be 0.");
                };
            };
            case (#item(itemId)) {
                if (items.get(itemId) == null) {
                    errors.add("Item id " # itemId # " does not exist.");
                };
            };
            case (#trait(traitId)) {
                if (traits.get(traitId) == null) {
                    errors.add("Trait id " # traitId # " does not exist.");
                };
            };
        };

        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
