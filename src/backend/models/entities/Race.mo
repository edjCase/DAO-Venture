import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";
import Action "Action";
import Item "Item";

module {

    public type Race = Entity.Entity and {
        startingItemIds : [Text];
        startingSkillActionIds : [Text];
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        race : Race,
        items : HashMap.HashMap<Text, Item.Item>,
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
        for (startingItemId in race.startingItemIds.vals()) {
            if (items.get(startingItemId) == null) {
                errors.add("Item not found: " # startingItemId);
            };
        };
        for (startingActionId in race.startingSkillActionIds.vals()) {
            if (actions.get(startingActionId) == null) {
                errors.add("Action not found: " # startingActionId);
            };
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
