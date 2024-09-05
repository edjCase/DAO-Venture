import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Trait "Trait";
import Entity "Entity";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";
import Action "Action";

module {

    public type Race = Entity.Entity and {
        startingTraitIds : [Text];
        actionIds : [Text];
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        race : Race,
        traits : HashMap.HashMap<Text, Trait.Trait>,
        actions : HashMap.HashMap<Text, Action.Action>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Race", race, errors);
        switch (race.unlockRequirement) {
            case (null) ();
            case (?unlockRequirement) {
                switch (UnlockRequirement.validate(unlockRequirement, achievements)) {
                    case (#err(err)) errors.append(Buffer.fromArray(err));
                    case (#ok) ();
                };
            };
        };
        for (startingTraitId in race.startingTraitIds.vals()) {
            if (traits.get(startingTraitId) == null) {
                errors.add("Trait not found: " # startingTraitId);
            };
        };
        for (actionId in race.actionIds.vals()) {
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
