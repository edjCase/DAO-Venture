import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import TextX "mo:xtended-text/TextX";
import CharacterModifier "CharacterModifier";
import Item "Item";
import Trait "Trait";
import UnlockRequirement "UnlockRequirement";
import Achievement "Achievement";

module {

    public type Class = {
        id : Text;
        name : Text;
        description : Text;
        modifiers : [CharacterModifier.CharacterModifier];
        unlockRequirement : UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        class_ : Class,
        existingClasses : HashMap.HashMap<Text, Class>,
        items : HashMap.HashMap<Text, Item.Item>,
        traits : HashMap.HashMap<Text, Trait.Trait>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(class_.id)) {
            errors.add("Class id cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(class_.name)) {
            errors.add("Class name cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(class_.description)) {
            errors.add("Class description cannot be empty.");
        };
        if (existingClasses.get(class_.id) != null) {
            errors.add("Class id " # class_.id # " already exists.");
        };
        switch (UnlockRequirement.validate(class_.unlockRequirement, achievements)) {
            case (#err(err)) errors.append(Buffer.fromArray(err));
            case (#ok) ();
        };
        for (modifier in class_.modifiers.vals()) {
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
