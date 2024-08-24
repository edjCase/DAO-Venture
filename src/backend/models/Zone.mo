import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import TextX "mo:xtended-text/TextX";

module {
    public type Zone = {
        id : Text;
        name : Text;
        description : Text;
    };

    public func validate(
        zone : Zone,
        exisingZones : HashMap.HashMap<Text, Zone>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(zone.id)) {
            errors.add("Zone id cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(zone.name)) {
            errors.add("Zone name cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(zone.description)) {
            errors.add("Zone description cannot be empty.");
        };
        if (exisingZones.get(zone.id) != null) {
            errors.add("Zone id " # zone.id # " already exists.");
        };
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
