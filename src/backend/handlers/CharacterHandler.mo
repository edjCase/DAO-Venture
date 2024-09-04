import Character "../models/Character";
import Int "mo:base/Int";
import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
module {
    public class Handler(data : Character.Character) {
        var character = data;

        public func get() : Character.Character {
            character;
        };

        public func getItems() : TrieSet.Set<Text> {
            character.itemIds;
        };

        public func setHealth(health : Nat) {
            character := {
                character with
                health = health;
            };
        };

        public func takeDamage(amount : Nat) : Bool {
            let newHealth : Int = character.health - amount;
            if (newHealth <= 0) {
                setHealth(0);
                false;
            } else {
                setHealth(Int.abs(newHealth));
                true;
            };
        };

        public func heal(amount : Nat) {
            let newHealth = Nat.min(character.health + amount, character.maxHealth);
            setHealth(newHealth);
        };

        public func addGold(amount : Nat) {
            character := {
                character with
                gold = character.gold + amount;
            };
        };

        public func removeGold(amount : Nat) : Bool {
            let newGold : Int = character.gold - amount;
            if (newGold < 0) {
                return false;
            };
            character := {
                character with
                gold = Int.abs(newGold);
            };
            true;
        };

        public func upgradeStat(kind : Character.CharacterStatKind, amount : Nat) {
            character := switch (kind) {
                case (#attack) {
                    {
                        character with
                        attack = character.attack + amount;
                    };
                };
                case (#defense) {
                    {
                        character with
                        defense = character.defense + amount;
                    };
                };
                case (#speed) {
                    {
                        character with
                        speed = character.speed + amount;
                    };
                };
                case (#magic) {
                    {
                        character with
                        magic = character.magic + amount;
                    };
                };
                case (#maxHealth) {
                    {
                        character with
                        maxHealth = character.maxHealth + amount;
                    };
                };
            };
        };

        public func addItem(itemId : Text) : Bool {
            let newItemIds = TrieSet.put<Text>(character.itemIds, itemId, Text.hash(itemId), Text.equal);
            if (TrieSet.size(newItemIds) == TrieSet.size(character.itemIds)) return false;
            character := {
                character with
                itemIds = newItemIds;
            };
            true;
        };

        public func removeItem(itemId : Text) : Bool {
            let newItemIds = TrieSet.delete<Text>(character.itemIds, itemId, Text.hash(itemId), Text.equal);
            if (TrieSet.size(newItemIds) == TrieSet.size(character.itemIds)) return false;
            character := {
                character with
                itemIds = newItemIds;
            };
            true;
        };

        public func addTrait(traitId : Text) : Bool {
            let newTraitIds = TrieSet.put<Text>(character.traitIds, traitId, Text.hash(traitId), Text.equal);
            if (TrieSet.size(newTraitIds) == TrieSet.size(character.traitIds)) return false;
            character := {
                character with
                traitIds = newTraitIds;
            };
            true;
        };

        public func removeTrait(traitId : Text) : Bool {
            let newTraitIds = TrieSet.delete<Text>(character.traitIds, traitId, Text.hash(traitId), Text.equal);
            if (TrieSet.size(newTraitIds) == TrieSet.size(character.traitIds)) return false;
            character := {
                character with
                traitIds = newTraitIds;
            };
            true;
        };
    };
};
