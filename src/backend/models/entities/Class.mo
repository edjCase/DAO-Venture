import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import CharacterModifier "../CharacterModifier";
import Item "Item";
import Trait "Trait";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";
import Entity "Entity";

module {

    public type Class = Entity.Entity and {
        weaponId : Text;
        modifiers : [CharacterModifier.CharacterModifier];
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        class_ : Class,
        existingClasses : HashMap.HashMap<Text, Class>,
        items : HashMap.HashMap<Text, Item.Item>,
        traits : HashMap.HashMap<Text, Trait.Trait>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Class", class_, existingClasses, errors);
        switch (class_.unlockRequirement) {
            case (null) ();
            case (?unlockRequirement) {
                switch (UnlockRequirement.validate(unlockRequirement, achievements)) {
                    case (#err(err)) errors.append(Buffer.fromArray(err));
                    case (#ok) ();
                };
            };
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
