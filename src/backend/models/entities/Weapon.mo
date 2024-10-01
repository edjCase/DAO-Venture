import Text "mo:base/Text";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";
import Action "Action";
import PixelImage "../PixelImage";

module Weapon {

    public type Weapon = Entity.Entity and {
        actionIds : [Text];
        image : PixelImage.PixelImage;
        unlockRequirement : UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        weapon : Weapon,
        actions : HashMap.HashMap<Text, Action.Action>,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Weapon", weapon, errors);
        for (actionId in weapon.actionIds.vals()) {
            if (actions.get(actionId) == null) {
                errors.add("Action not found: " # actionId);
            };
        };
        switch (UnlockRequirement.validate(weapon.unlockRequirement, achievements)) {
            case (#err(err)) errors.append(Buffer.fromArray(err));
            case (#ok) ();
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
