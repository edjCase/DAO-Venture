import Character "../models/Character";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import IterTools "mo:itertools/Iter";

module {
    public class Handler(data : Character.Character) {
        var character = data;

        public func get() : Character.Character {
            character;
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

        public func addItemToSlot(itemId : Text, slotIndex : Nat) : Result.Result<{ removedItemId : ?Text }, { #invalidSlot }> {
            if (slotIndex >= character.inventorySlots.size()) {
                return #err(#invalidSlot);
            };
            let removedItemId = addItemInternal(itemId, slotIndex);
            #ok({ removedItemId });
        };

        public func addItem(itemId : Text) : Result.Result<(), { #inventoryFull }> {
            let nextEmptySlot = IterTools.findIndex(
                character.inventorySlots.vals(),
                func(slot : Character.InventorySlot) : Bool {
                    slot.itemId == null;
                },
            );
            switch (nextEmptySlot) {
                case (null) #err(#inventoryFull);
                case (?slotIndex) {
                    let null = addItemInternal(itemId, slotIndex) else Debug.trap("Tried to add item to empty slot '" # Nat.toText(slotIndex) # "' but failed");
                    #ok;
                };
            };
        };

        private func addItemInternal(itemId : Text, slotIndex : Nat) : ?Text {
            let thawedSlots = Array.thaw<Character.InventorySlot>(character.inventorySlots);
            let removedItemId = thawedSlots[slotIndex].itemId;
            thawedSlots[slotIndex] := { itemId = ?itemId };
            let newSlots = Array.freeze(thawedSlots);
            character := {
                character with
                inventorySlots = newSlots;
            };
            removedItemId;
        };

        public func removeItem(itemId : Text, removeAll : Bool) : Nat {
            var removedCount = 0;
            let newSlots = character.inventorySlots.vals()
            |> Iter.map(
                _,
                func(slot : Character.InventorySlot) : Character.InventorySlot {
                    if (slot.itemId == ?itemId) {
                        if (removeAll and removedCount >= 1) {
                            removedCount += 1;
                            { itemId = null };
                        } else {
                            slot;
                        };
                    } else {
                        slot;
                    };
                },
            )
            |> Iter.toArray(_);
            if (removedCount == 0) {
                return 0; // No item was removed
            };
            character := {
                character with
                inventorySlots = newSlots;
            };
            removedCount;
        };

        public func removeItemBySlot(slotIndex : Nat) : Result.Result<{ removedItemId : ?Text }, { #invalidSlot }> {
            if (slotIndex >= character.inventorySlots.size()) {
                return #err(#invalidSlot);
            };
            let thawedSlots = Array.thaw<Character.InventorySlot>(character.inventorySlots);
            let removedItemId = thawedSlots[slotIndex].itemId;
            switch (removedItemId) {
                case (null) ();
                case (?_) {
                    thawedSlots[slotIndex] := { itemId = null };
                    let newSlots = Array.freeze(thawedSlots);
                    character := {
                        character with
                        inventorySlots = newSlots;
                    };
                };
            };
            #ok({ removedItemId = removedItemId });
        };

        public func swapWeapon(weaponId : Text) : Text {
            let oldWeaponId = character.weaponId;
            character := {
                character with
                weaponId = weaponId;
            };
            oldWeaponId;
        };
    };
};
