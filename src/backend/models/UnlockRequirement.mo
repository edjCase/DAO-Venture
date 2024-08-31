import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import TextX "mo:xtended-text/TextX";
import Achievement "entities/Achievement";

module {
    public type UnlockRequirement = {
        #acheivementId : Text;
    };

    public func validate(
        unlockRequirement : UnlockRequirement,
        acheivementIds : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        switch (unlockRequirement) {
            case (#acheivementId(acheivementId)) {
                if (TextX.isEmptyOrWhitespace(acheivementId)) {
                    errors.add("Unlock requirement achievement id cannot be empty.");
                };
                // Limit size of id to 32 characters
                if (acheivementId.size() > 32) {
                    errors.add("Unlock requirement achievement id cannot be longer than 32 characters.");
                };
                if (acheivementIds.get(acheivementId) == null) {
                    errors.add("Unlock requirement achievement id " # acheivementId # " does not exist.");
                };
            };
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
