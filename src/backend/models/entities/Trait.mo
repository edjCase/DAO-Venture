import Result "mo:base/Result";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Entity "Entity";
import PixelImage "../PixelImage";

module {

    public type Trait = Entity.Entity and {
        image : PixelImage.PixelImage;
    };

    public func validate(
        trait : Trait,
        existingTraits : HashMap.HashMap<Text, Trait>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        Entity.validate("Trait", trait, existingTraits, errors);
        if (errors.size() < 1) {
            return #ok;
        };
        #err(Buffer.toArray(errors));
    };
};
