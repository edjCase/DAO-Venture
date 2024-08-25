import HashMap "mo:base/HashMap";
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
        existingEntities : HashMap.HashMap<Text, TEntity>,
        errors : Buffer.Buffer<Text>,
    ) {
        if (TextX.isEmptyOrWhitespace(entity.id)) {
            errors.add(entityName # " id cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(entity.name)) {
            errors.add(entityName # " name cannot be empty.");
        };
        if (TextX.isEmptyOrWhitespace(entity.description)) {
            errors.add(entityName # " description cannot be empty.");
        };
        switch (existingEntities.get(entity.id)) {
            case (null) ();
            case (?_) errors.add(entityName # " id " # entity.id # " already exists.");
        };
    };
};
