import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Character "models/Character";
import Class "models/entities/Class";
import Race "models/entities/Race";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generate(
        class_ : Class.Class,
        race : Race.Race,
    ) : Character.Character {
        var gold : Nat = 0;
        var maxHealth : Nat = 100;
        var health : Nat = maxHealth;
        var itemIds = TrieSet.empty<Text>();
        var attack : Int = 0;
        var defense : Int = 0;
        var speed : Int = 0;
        var magic : Int = 0;

        func addItem(itemId : Text) {
            itemIds := TrieSet.put(itemIds, itemId, Text.hash(itemId), Text.equal);
        };

        for (startingItemId in class_.startingItemIds.vals()) {
            addItem(startingItemId);
        };

        {
            health = health;
            maxHealth = maxHealth;
            gold = gold;
            classId = class_.id;
            raceId = race.id;
            attack = attack;
            defense = defense;
            speed = speed;
            magic = magic;
            itemIds = itemIds;
            weaponId = class_.weaponId;
        };
    };

};
