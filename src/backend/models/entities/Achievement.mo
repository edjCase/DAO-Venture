import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Entity "Entity";

module {
    public type Achievement = Entity.Entity and {

    };

    public func validate(
        achievement : Achievement,
        exisingAchievements : HashMap.HashMap<Text, Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Achievement", achievement, exisingAchievements, errors);
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
