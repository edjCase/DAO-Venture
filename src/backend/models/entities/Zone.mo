import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";

module {
    public type Zone = Entity.Entity and {
        difficulty : ZoneDifficulty;
        unlockRequirement : UnlockRequirement.UnlockRequirement;
    };

    public type ZoneDifficulty = {
        #easy;
        #medium;
        #hard;
    };

    public func validate(
        zone : Zone,
        achievements : HashMap.HashMap<Text, Achievement.Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Zone", zone, errors);
        switch (UnlockRequirement.validate(zone.unlockRequirement, achievements)) {
            case (#err(err)) errors.append(Buffer.fromArray(err));
            case (#ok) ();
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
