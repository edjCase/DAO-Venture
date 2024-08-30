import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Item "Item";
import Trait "Trait";
import Entity "Entity";
import CharacterModifier "../CharacterModifier";

module {

    public type Race = Entity.Entity and {
        modifiers : [CharacterModifier.CharacterModifier];
    };

    public func validate(
        race : Race,
        items : HashMap.HashMap<Text, Item.Item>,
        traits : HashMap.HashMap<Text, Trait.Trait>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Race", race, errors);
        for (modifier in race.modifiers.vals()) {
            switch (CharacterModifier.validate(modifier, items, traits)) {
                case (#err(err)) errors.append(Buffer.fromArray(err));
                case (#ok) ();
            };
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
