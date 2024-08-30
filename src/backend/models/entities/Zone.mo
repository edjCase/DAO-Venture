import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";

module {
    public type Zone = Entity.Entity and {
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        zone : Zone,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Zone", zone, errors);
        switch (zone.unlockRequirement) {
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
