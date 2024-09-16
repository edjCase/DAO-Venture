import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Class "entities/Class";
import Race "entities/Race";
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

    public func getActionIds(
        character : Character,
        classes : HashMap.HashMap<Text, Class.Class>,
        races : HashMap.HashMap<Text, Race.Race>,
        items : HashMap.HashMap<Text, Item.Item>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
    ) : Buffer.Buffer<Text> {
        let allActionIds = Buffer.Buffer<Text>(10);

        let ?class_ = classes.get(character.classId) else Debug.trap("Class not found: " # character.classId);
        allActionIds.append(Buffer.fromArray(class_.startingSkillActionIds));

        let ?race = races.get(character.raceId) else Debug.trap("Race not found: " # character.raceId);
        allActionIds.append(Buffer.fromArray(race.startingSkillActionIds));

        let ?weapon = weapons.get(character.weaponId) else Debug.trap("Weapon not found: " # character.weaponId);
        allActionIds.append(Buffer.fromArray(weapon.actionIds));

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
        allActionIds.append(Buffer.fromIter(itemActionIds));

        allActionIds;
    };
};
