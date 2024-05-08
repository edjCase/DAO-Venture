import Text "mo:base/Text";

module {

    public type Trait = {
        id : Text;
        name : Text;
        description : Text;
    };

    public func hash(trait : Trait) : Nat32 = Text.hash(trait.id);

    public func equal(a : Trait, b : Trait) : Bool = a.id == b.id;
};
