import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import TextX "mo:xtended-text/TextX";

module {

    public type Trait = {
        id : Text;
        name : Text;
        description : Text;
    };

    public func validate(
        trait : Trait,
        existingTraits : HashMap.HashMap<Text, Trait>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(trait.id)) {
            errors.add("Trait id cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(trait.name)) {
            errors.add("Trait name cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(trait.description)) {
            errors.add("Trait description cannot be empty.");
        };
        if (existingTraits.get(trait.id) != null) {
            errors.add("Trait id " # trait.id # " already exists.");
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
