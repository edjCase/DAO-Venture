import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
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

    public type Processor = {
        log : (Text) -> ();
        takeDamage : (Nat) -> Bool; // True -> Alive, False -> Dead
        heal : (Nat) -> ();
        addGold : (Nat) -> ();
        upgradeStat : (Character.CharacterStatKind, Nat) -> ();
        reward : () -> ();
        removeGold : (Nat) -> Bool; // True -> Had enough, False -> Not enough
        addItem : (Text) -> Bool; // True -> Didnt have item, False -> Had item
        removeItem : (Text) -> Bool; // True -> Had item to remove, False -> No item to remove
        loseRandomItem : () -> Bool; // True -> Had an item to lose, False -> No items to lose
        addTrait : (Text) -> Bool; // True -> Didnt have trait, False -> Had trait
        removeTrait : (Text) -> Bool; // True -> Had trait to remove, False -> No trait to remove
    };

};
