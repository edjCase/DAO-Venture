import Character "../models/Character";
import Int "mo:base/Int";
import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
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

        public func getItems() : TrieSet.Set<Text> {
            character.itemIds;
        };

        public func takeDamage(amount : Nat) : Bool {
            let newHealth : Int = character.health - amount;
            if (newHealth <= 0) {
                character := {
                    character with
                    health = 0;
                };
                false;
            } else {
                character := {
                    character with
                    health = Int.abs(newHealth);
                };
                true;
            };
        };

        public func heal(amount : Nat) {
            // TODO max health?
            character := {
                character with
                health = character.health + amount;
            };
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
            let newStats = switch (kind) {
                case (#attack) {
                    {
                        character.stats with
                        attack = character.stats.attack + amount;
                    };
                };
                case (#defense) {
                    {
                        character.stats with
                        defense = character.stats.defense + amount;
                    };
                };
                case (#speed) {
                    {
                        character.stats with
                        speed = character.stats.speed + amount;
                    };
                };
                case (#magic) {
                    {
                        character.stats with
                        magic = character.stats.magic + amount;
                    };
                };
            };
            character := {
                character with
                stats = newStats;
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
