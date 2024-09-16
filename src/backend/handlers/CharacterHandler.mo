import Character "../models/Character";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import IterTools "mo:itertools/Iter";
import Action "../models/entities/Action";
import Weapon "../models/entities/Weapon";
import Item "../models/entities/Item";

module Module {
    public class Handler(data : Character.Character) {
        var character = data;

        public func get() : Character.Character {
            character;
        };

        public func calculateAttributes(
            weapons : HashMap.HashMap<Text, Weapon.Weapon>,
            items : HashMap.HashMap<Text, Item.Item>,
            actions : HashMap.HashMap<Text, Action.Action>,
        ) : Character.CharacterAttributes {
            Module.calculateAttributes(character, weapons, items, actions);
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

    public func calculateAttributes(
        character : Character.Character,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        items : HashMap.HashMap<Text, Item.Item>,
        actions : HashMap.HashMap<Text, Action.Action>,
    ) : Character.CharacterAttributes {
        var strength : Int = 0;
        var dexterity : Int = 0;
        var wisdom : Int = 0;
        var charisma : Int = 0;

        let allCharacterActions = Character.getActions(character, items, weapons);
        for (characterAction in allCharacterActions.vals()) {
            let ?action = actions.get(characterAction.actionId) else Debug.trap("Action not found: " # characterAction.actionId);
            for (effect in action.scenarioEffects.vals()) {
                switch (effect) {
                    case (#attribute(attribute)) {
                        switch (attribute.attribute) {
                            case (#strength) strength += attribute.value;
                            case (#dexterity) dexterity += attribute.value;
                            case (#wisdom) wisdom += attribute.value;
                            case (#charisma) charisma += attribute.value;
                        };
                    };
                };
            };
        };

        {
            character with
            strength = strength;
            dexterity = dexterity;
            wisdom = wisdom;
            charisma = charisma;
        };
    };
};
