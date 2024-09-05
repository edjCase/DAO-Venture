import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Trait "Trait";
import Entity "Entity";
import UnlockRequirement "../UnlockRequirement";
import Achievement "Achievement";

module {

    public type Race = Entity.Entity and {
        startingTraitIds : [Text];
        cardIds : [Text];
        unlockRequirement : ?UnlockRequirement.UnlockRequirement;
    };

    public func validate(
        race : Race,
        traits : HashMap.HashMap<Text, Trait.Trait>,
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
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
