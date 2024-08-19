import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import TextX "mo:xtended-text/TextX";

module {

    public type Item = {
        id : Text;
        name : Text;
        description : Text;
    };

    public func validate(
        item : Item,
        exisingItems : HashMap.HashMap<Text, Item>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(item.id)) {
            errors.add("Item id cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(item.name)) {
            errors.add("Item name cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(item.description)) {
            errors.add("Item description cannot be empty.");
        };
        if (exisingItems.get(item.id) != null) {
            errors.add("Item id " # item.id # " already exists.");
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
