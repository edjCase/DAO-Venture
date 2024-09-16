import Buffer "mo:base/Buffer";
import TextX "mo:xtended-text/TextX";

module {
    public type Entity = {
        id : Text;
        name : Text;
        description : Text;
    };

    public func validate<TEntity <: Entity>(
        entityName : Text,
        entity : Entity,
        errors : Buffer.Buffer<Text>,
    ) {
        if (TextX.isEmptyOrWhitespace(entity.id)) {
            errors.add(entityName # " id cannot be empty.");
        };
        // Limit size of id to 32 characters
        if (entity.id.size() > 32) {
            errors.add(entityName # " id cannot be longer than 32 characters.");
        };
        if (TextX.isEmptyOrWhitespace(entity.name)) {
            errors.add(entityName # " name cannot be empty.");
        };
        // Limit size of name to 32 characters
        if (entity.name.size() > 32) {
            errors.add(entityName # " name cannot be longer than 32 characters.");
        };
        if (TextX.isEmptyOrWhitespace(entity.description)) {
            errors.add(entityName # " description cannot be empty.");
        };
        // Limit size of description to 256 characters
        if (entity.description.size() > 256) {
            errors.add(entityName # " description cannot be longer than 256 characters.");
        };
    };
};
