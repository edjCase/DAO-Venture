import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import TextX "mo:xtended-text/TextX";
import CharacterModifier "CharacterModifier";
import Item "Item";
import Trait "Trait";

module {

    public type Race = {
        id : Text;
        name : Text;
        description : Text;
        modifiers : [CharacterModifier.CharacterModifier];
    };

    public func validate(
        race : Race,
        existingRaces : HashMap.HashMap<Text, Race>,
        items : HashMap.HashMap<Text, Item.Item>,
        traits : HashMap.HashMap<Text, Trait.Trait>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(race.id)) {
            errors.add("Race id cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(race.name)) {
            errors.add("Race name cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(race.description)) {
            errors.add("Race description cannot be empty.");
        };
        if (existingRaces.get(race.id) != null) {
            errors.add("Race id " # race.id # " already exists.");
        };
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
