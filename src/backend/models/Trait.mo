import Text "mo:base/Text";
import Skill "Skill";
module {
    public type Effect = {
        #skill : {
            skill : Skill.Skill;
            delta : Int;
        };
    };

    public type Trait = {
        id : Text;
        name : Text;
        description : Text;
        effects : [Effect];
    };

    public func hash(trait : Trait) : Nat32 = Text.hash(trait.id);

    public func equal(a : Trait, b : Trait) : Bool = a.id == b.id;
};
