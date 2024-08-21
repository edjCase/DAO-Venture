import Text "mo:base/Text";
import Result "mo:base/Result";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
module {

    public type Image = {
        id : Text;
        data : Blob;
        kind : ImageKind;
    };

    public type ImageKind = {
        #png;
    };

    public func validate(
        image : Image,
        existingImages : HashMap.HashMap<Text, Image>,
    ) : Result.Result<(), [Text]> {
        let errors = Buffer.Buffer<Text>(0);
        if (image.data.size() > 200 * 1024) {
            errors.add("Scenario image is too large. Max size is 200KB");
        };
        if (existingImages.get(image.id) != null) {
            errors.add("Duplicate image id: " # image.id);
        };

        if (errors.size() > 0) {
            return #err(Buffer.toArray(errors));
        };
        return #ok;
    };
};
