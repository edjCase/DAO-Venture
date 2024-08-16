import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
import Item "Item";
import Trait "Trait";
import Character "Character";
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
        takeDamage : (Nat) -> Bool; // True -> Alive, False -> Dead
        heal : (Nat) -> ();
        addGold : (Nat) -> ();
        upgradeStat : (Character.CharacterStatKind, Nat) -> ();
        reward : () -> ();
        removeGold : (Nat) -> Bool; // True -> Had enough, False -> Not enough
        addItem : (Item.Item) -> Bool; // True -> Didnt have item, False -> Had item
        removeItem : (Item.Item) -> Bool; // True -> Had item to remove, False -> No item to remove
        loseRandomItem : () -> Bool; // True -> Had an item to lose, False -> No items to lose
        addTrait : (Trait.Trait) -> Bool; // True -> Didnt have trait, False -> Had trait
        removeTrait : (Trait.Trait) -> Bool; // True -> Had trait to remove, False -> No trait to remove
    };

};
