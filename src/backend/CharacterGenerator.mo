import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Character "models/Character";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generate(
        class_ : Character.Class,
        race : Character.Race,
    ) : Character.Character {
        var gold : Nat = 0;
        var health : Nat = 100;
        var itemIds = TrieSet.empty<Text>();
        var traitIds = TrieSet.empty<Text>();
        var attack : Int = 0;
        var defense : Int = 0;
        var speed : Int = 0;
        var magic : Int = 0;

        func addItem(item : Text) {
            itemIds := TrieSet.put(itemIds, item, Text.hash(item), Text.equal);
        };

        func addTrait(trait : Text) {
            traitIds := TrieSet.put(traitIds, trait, Text.hash(trait), Text.equal);
        };

        func applyEffect(effect : Character.Effect) {
            switch (effect) {
                case (#attack(delta)) attack += delta;
                case (#defense(delta)) defense += delta;
                case (#speed(delta)) speed += delta;
                case (#magic(delta)) magic += delta;
                case (#gold(amount)) gold += amount;
                case (#health(delta)) {
                    if (delta < 0) {
                        // min health is 1
                        health := Int.abs(Int.max(1, health + delta));
                    } else {
                        health += Int.abs(delta);
                    };
                };
                case (#item(itemId)) addItem(itemId);
                case (#trait(traitId)) addTrait(traitId);
            };
        };

        for (effect in class_.effects.vals()) {
            applyEffect(effect);
        };

        for (effect in race.effects.vals()) {
            applyEffect(effect);
        };

        {
            health = health;
            gold = gold;
            classId = class_.id;
            raceId = race.id;
            stats = {
                attack = attack;
                defense = defense;
                speed = speed;
                magic = magic;
            };
            itemIds = itemIds;
            traitIds = traitIds;
        };
    };

};
