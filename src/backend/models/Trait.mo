import Text "mo:base/Text";
import Skill "Skill";
module {
    public type Effect = {
        #skill : {
            skill : ?Skill.Skill;
            delta : Int;
        };
    };

    public type Trait = {
        // TODO Look into hashing the values or something
        // for the ID and maybe some versioning, so that the
        // data is immutable. Can retire bad ones and add new ones
        // BUT will that be an issue for updating the game or can versions
        // make that ok?
        id : Text;
        name : Text;
        description : Text;
        effects : [Effect];
    };

    public func hash(trait : Trait) : Nat32 = Text.hash(trait.id);

    public func equal(a : Trait, b : Trait) : Bool = a.id == b.id;
};
