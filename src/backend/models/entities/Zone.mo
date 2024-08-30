import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import Entity "Entity";

module {
    public type Zone = Entity.Entity and {

    };

    public func validate(
        zone : Zone
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Zone", zone, errors);
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
