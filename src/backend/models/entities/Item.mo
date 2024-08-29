import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";

module {

    public type Item = Entity.Entity and {
        // image : PixelImage;
    };

    public func validate(
        item : Item,
        exisingItems : HashMap.HashMap<Text, Item>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Item", item, exisingItems, errors);
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
