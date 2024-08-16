import Character "../models/Character";
import Int "mo:base/Int";
import TrieSet "mo:base/TrieSet";
import Item "../models/Item";
import Trait "../models/Trait";
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

        public func getItems() : TrieSet.Set<Item.Item> {
            character.items;
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

        public func addItem(item : Item.Item) : Bool {
            let newItems = TrieSet.put<Item.Item>(character.items, item, Item.hash(item), Item.equal);
            if (TrieSet.size(newItems) == TrieSet.size(character.items)) return false;
            character := {
                character with
                items = newItems;
            };
            true;
        };

        public func removeItem(item : Item.Item) : Bool {
            let newItems = TrieSet.delete<Item.Item>(character.items, item, Item.hash(item), Item.equal);
            if (TrieSet.size(newItems) == TrieSet.size(character.items)) return false;
            character := {
                character with
                items = newItems;
            };
            true;
        };

        public func addTrait(trait : Trait.Trait) : Bool {
            let newTraits = TrieSet.put<Trait.Trait>(character.traits, trait, Trait.hash(trait), Trait.equal);
            if (TrieSet.size(newTraits) == TrieSet.size(character.traits)) return false;
            character := {
                character with
                traits = newTraits;
            };
            true;
        };

        public func removeTrait(trait : Trait.Trait) : Bool {
            let newTraits = TrieSet.delete<Trait.Trait>(character.traits, trait, Trait.hash(trait), Trait.equal);
            if (TrieSet.size(newTraits) == TrieSet.size(character.traits)) return false;
            character := {
                character with
                traits = newTraits;
            };
            true;
        };
    };
};
