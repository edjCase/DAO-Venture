import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import TextX "mo:xtended-text/TextX";
import Achievement "entities/Achievement";

module {
    public type UnlockRequirement = {
        #none;
        #achievementId : Text;
    };

    public func validate(
        unlockRequirement : UnlockRequirement,
        achievementIds : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        switch (unlockRequirement) {
            case (#none) ();
            case (#achievementId(achievementId)) {
                if (TextX.isEmptyOrWhitespace(achievementId)) {
                    errors.add("Unlock requirement achievement id cannot be empty.");
                };
                // Limit size of id to 32 characters
                if (achievementId.size() > 32) {
                    errors.add("Unlock requirement achievement id cannot be longer than 32 characters.");
                };
                if (achievementIds.get(achievementId) == null) {
                    errors.add("Unlock requirement achievement id " # achievementId # " does not exist.");
                };
            };
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
