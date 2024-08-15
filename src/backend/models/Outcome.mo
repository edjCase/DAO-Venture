import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Item "Item";
import Trait "Trait";
module {

    public type Outcome = {
        choice : ?Text;
        messages : [Text];
    };

    public type ChoiceRequirement = {
        #all : [ChoiceRequirement];
        #any : [ChoiceRequirement];
        #item : Item.Item;
        #trait : Trait.Trait;
    };

    public type Processor = {
        log : (Text) -> ();
        takeDamage : (Nat) -> { #alive; #dead };
        reward : () -> ();
        addGold : (Nat) -> ();
        removeGold : (Nat) -> Bool; // True -> Had enough, False -> Not enough
        addItem : (Item.Item) -> ();
        removeItem : (Item.Item) -> ();
        // addTrait : (Trait) -> ();
        // removeTrait : (Trait) -> { hadTrait : Bool };
    };

};
