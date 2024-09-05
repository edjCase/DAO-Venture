import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Character "models/Character";
import Class "models/entities/Class";
import Race "models/entities/Race";
import Weapon "models/entities/Weapon";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generate(
        class_ : Class.Class,
        race : Race.Race,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
    ) : Character.Character {
        var gold : Nat = 0;
        var maxHealth : Nat = 100;
        var health : Nat = maxHealth;
        var itemIds = TrieSet.empty<Text>();
        var traitIds = TrieSet.empty<Text>();
        var attack : Int = 0;
        var defense : Int = 0;
        var speed : Int = 0;
        var magic : Int = 0;

        func addTrait(trait : Text) {
            traitIds := TrieSet.put(traitIds, trait, Text.hash(trait), Text.equal);
        };

        for (startingTraitId in class_.startingTraitIds.vals()) {
            addTrait(startingTraitId);
        };

        for (startingTraitId in race.startingTraitIds.vals()) {
            addTrait(startingTraitId);
        };

        let ?weapon = weapons.get(class_.weaponId) else Debug.trap("Weapon not found: " # class_.weaponId);

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
            traitIds = traitIds;
            weapon = weapon;
        };
    };

};
