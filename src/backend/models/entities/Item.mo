import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import PixelImage "../PixelImage";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";
import Action "Action";

module {

    public type Item = Entity.Entity and {
        image : PixelImage.PixelImage;
        actionIds : [Text];
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        item : Item,
        actions : HashMap.HashMap<Text, Action.Action>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Item", item, errors);

        for (actionId in item.actionIds.vals()) {
            if (actions.get(actionId) == null) {
                errors.add("Action not found: " # actionId);
            };
        };
        switch (item.unlockRequirement) {
            case (null) ();
            case (?unlockRequirement) {
                switch (UnlockRequirement.validate(unlockRequirement, achievements)) {
                    case (#err(err)) errors.append(Buffer.fromArray(err));
                    case (#ok) ();
                };
            };
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
