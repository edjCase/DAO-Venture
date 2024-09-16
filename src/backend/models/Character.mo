import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Weapon "entities/Weapon";
import IterTools "mo:itertools/Iter";
import Item "entities/Item";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Character = {
        health : Nat;
        maxHealth : Nat;
        gold : Nat;
        classId : Text;
        raceId : Text;
        weaponId : Text;
        inventorySlots : [InventorySlot];
        skillActionIds : [Text];
    };

    public type CharacterAttributes = {
        strength : Int;
        dexterity : Int;
        wisdom : Int;
        charisma : Int;
    };

    public type InventorySlot = {
        itemId : ?Text;
    };

    public type CharacterAction = {
        actionId : Text;
        kind : CharacterActionKind;
    };

    public type CharacterActionKind = {
        #skill;
        #item;
        #weapon;
    };

    public func getActions(
        character : Character,
        items : HashMap.HashMap<Text, Item.Item>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
    ) : Buffer.Buffer<CharacterAction> {
        let allActions = Buffer.Buffer<CharacterAction>(10);

        func addActionIds(actionIds : Iter.Iter<Text>, kind : CharacterActionKind) {
            for (actionId in actionIds) {
                allActions.add({ actionId = actionId; kind = kind });
            };
        };

        addActionIds(character.skillActionIds.vals(), #skill);

        let ?weapon = weapons.get(character.weaponId) else Debug.trap("Weapon not found: " # character.weaponId);
        addActionIds(weapon.actionIds.vals(), #weapon);

        let itemActionIds = character.inventorySlots.vals()
        |> IterTools.mapFilter<InventorySlot, Iter.Iter<Text>>(
            _,
            func(slot : InventorySlot) : ?Iter.Iter<Text> {
                switch (slot.itemId) {
                    case (null) null;
                    case (?itemId) {
                        let ?item = items.get(itemId) else Debug.trap("Item not found: " # itemId);
                        ?item.actionIds.vals();
                    };
                };
            },
        )
        |> IterTools.flatten(_);
        addActionIds(itemActionIds, #item);

        allActions;
    };
};
