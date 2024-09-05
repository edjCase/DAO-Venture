import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Trait "Trait";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";
import Entity "Entity";
import Action "Action";

module {

    public type Class = Entity.Entity and {
        weaponId : Text;
        startingTraitIds : [Text];
        actionIds : [Text];
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        class_ : Class,
        traits : HashMap.HashMap<Text, Trait.Trait>,
        actions : HashMap.HashMap<Text, Action.Action>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Class", class_, errors);
        switch (class_.unlockRequirement) {
            case (null) ();
            case (?unlockRequirement) {
                switch (UnlockRequirement.validate(unlockRequirement, achievements)) {
                    case (#err(err)) errors.append(Buffer.fromArray(err));
                    case (#ok) ();
                };
            };
        };
        for (startingTraitId in class_.startingTraitIds.vals()) {
            if (traits.get(startingTraitId) == null) {
                errors.add("Trait not found: " # startingTraitId);
            };
        };
        for (actionId in class_.actionIds.vals()) {
            if (actions.get(actionId) == null) {
                errors.add("Action not found: " # actionId);
            };
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
