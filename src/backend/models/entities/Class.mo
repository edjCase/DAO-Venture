import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";
import Entity "Entity";
import Action "Action";
import Item "Item";
import PixelImage "../PixelImage";

module {

    public type Class = Entity.Entity and {
        weaponId : Text;
        startingItemIds : [Text];
        startingSkillActionIds : [Text];
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
        image : PixelImage.PixelImage;
    };

    public func validate(
        class_ : Class,
        items : HashMap.HashMap<Text, Item.Item>,
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
        for (startingItemId in class_.startingItemIds.vals()) {
            if (items.get(startingItemId) == null) {
                errors.add("Item not found: " # startingItemId);
            };
        };
        for (startingActionId in class_.startingSkillActionIds.vals()) {
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
