import Character "../models/Character";
import Int "mo:base/Int";
import Array "mo:base/Array";
import Item "../models/Item";
module {
    public type StableData = {
        character : Character.Character;
    };
    public class Handler(stableData : StableData) {
        var character = stableData.character;

        public func toStableData() : StableData {
            {
                character = character;
            };
        };

        public func get() : Character.Character {
            character;
        };

        public func takeDamage(amount : Nat) : { #alive; #dead } {
            let newHealth : Int = character.health - amount;
            if (newHealth <= 0) {
                character := {
                    character with
                    health = 0;
                };
                #dead;
            } else {
                character := {
                    character with
                    health = Int.abs(newHealth);
                };
                #alive;
            };
        };

        public func addGold(amount : Nat) {
            character := {
                character with
                gold = character.gold + amount;
            };
        };

        public func addItem(item : Item.Item) {
            character := {
                character with
                items = Array.append(character.items, [item]);
            };
        };
    };
};
