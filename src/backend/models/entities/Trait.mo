import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import PixelImage "../PixelImage";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";

module {

    public type Trait = Entity.Entity and {
        image : PixelImage.PixelImage;
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        trait : Trait,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Trait", trait, errors);
        switch (trait.unlockRequirement) {
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
