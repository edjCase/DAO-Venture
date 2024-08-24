import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import TextX "mo:xtended-text/TextX";

module {
    public type Achievement = {
        id : Text;
        name : Text;
        description : Text;
    };

    public func validate(
        achievement : Achievement,
        exisingAchievements : HashMap.HashMap<Text, Achievement>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(achievement.id)) {
            errors.add("Achievement id cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(achievement.name)) {
            errors.add("Achievement name cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(achievement.description)) {
            errors.add("Achievement description cannot be empty.");
        };
        if (exisingAchievements.get(achievement.id) != null) {
            errors.add("Achievement id " # achievement.id # " already exists.");
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
