import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Item "Item";
import Character "Character";
module {

    public type Outcome<TChoice> = {
        choice : ?TChoice;
        description : [Text];
    };

    public type ChoiceRequirement = {
        #all : [ChoiceRequirement];
        #any : [ChoiceRequirement];
        #item : Item.Item;
        #trait : Character.Trait;
    };

    public type Processor = {
        log : (Text) -> ();
        takeDamage : (Nat) -> { #alive; #dead };
        reward : () -> ();
        addGold : (Nat) -> ();
        addItem : (Item.Item) -> ();
        // removeItem : (Item) -> { hadItem : Bool };
        // addTrait : (Trait) -> ();
        // removeTrait : (Trait) -> { hadTrait : Bool };
    };

};
