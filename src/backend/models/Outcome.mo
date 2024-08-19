import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Character "Character";
module {

    public type Outcome = {
        choiceOrUndecided : ?Text;
        messages : [Text];
    };

    public type ChoiceRequirement = {
        #all : [ChoiceRequirement];
        #any : [ChoiceRequirement];
        #stat : (Character.CharacterStatKind, Nat);
        #item : Text;
        #trait : Text;
    };
};
