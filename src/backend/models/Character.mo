import Item "Item";
import Trait "Trait";
import TrieSet "mo:base/TrieSet";
import Prelude "mo:base/Prelude";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Character = {
        health : Nat;
        gold : Nat;
        class_ : Class;
        race : Race;
        stats : CharacterStats;
        items : TrieSet.Set<Item.Item>;
        traits : TrieSet.Set<Trait.Trait>;
    };

    public type State = {
        id : Text;
        name : Text;
        description : Text;
    };

    public type Class = {
        #warrior;
        #mage;
        #rogue;
        #archer;
    };

    public func toStateClass(class_ : Class) : State {
        switch (class_) {
            case (#warrior) {
                {
                    id = "warrior";
                    name = "Warrior";
                    description = "A warrior is a master of combat, using their strength and skill to defeat their foes.";
                };
            };
            case (#mage) {
                {
                    id = "mage";
                    name = "Mage";
                    description = "A mage is a master of magic, using their knowledge of the arcane to cast powerful spells.";
                };
            };
            case (#rogue) {
                {
                    id = "rogue";
                    name = "Rogue";
                    description = "A rogue is a master of stealth, using their cunning and agility to outmaneuver their foes.";
                };
            };
            case (#archer) {
                {
                    id = "archer";
                    name = "Archer";
                    description = "An archer is a master of ranged combat, using their precision and skill to strike from a distance.";
                };
            };
        };
    };

    public type Race = {
        #human;
        #elf;
        #dwarf;
        #halfling;
        #faerie;
    };

    public func toStateRace(race : Race) : State {
        switch (race) {
            case (#human) {
                {
                    id = "human";
                    name = "Human";
                    description = "Humans are a versatile and adaptable";
                };
            };
            case (#elf) {
                {
                    id = "elf";
                    name = "Elf";
                    description = "Elves are a graceful and magical";
                };
            };
            case (#dwarf) {
                {
                    id = "dwarf";
                    name = "Dwarf";
                    description = "Dwarves are a sturdy and resilient";
                };
            };
            case (#halfling) {
                {
                    id = "halfling";
                    name = "Halfling";
                    description = "Halflings are a small and nimble";
                };
            };
            case (#faerie) {
                {
                    id = "faerie";
                    name = "Faerie";
                    description = "Faeries are a mysterious and magical";
                };
            };
        };
    };

    public type CharacterStats = {
        attack : Int;
        defense : Int;
        speed : Int;
        magic : Int;
    };

    public type CharacterStatKind = {
        #attack;
        #defense;
        #speed;
        #magic;
    };

    public func toTextStatKind(kind : CharacterStatKind) : Text {
        switch (kind) {
            case (#attack) "attack";
            case (#defense) "defense";
            case (#speed) "speed";
            case (#magic) "magic";
        };
    };

    public func generate(prng : Prng) : Character {
        // TODO procedurally generate
        var gold : Nat = 0;
        var health : Nat = 100;
        var items = TrieSet.empty<Item.Item>();
        var traits = TrieSet.empty<Trait.Trait>();
        var attack : Int = 0;
        var defense : Int = 0;
        var speed : Int = 0;
        var magic : Int = 0;

        func addItem(item : Item.Item) {
            items := TrieSet.put(items, item, Item.hash(item), Item.equal);
        };

        func addTrait(trait : Trait.Trait) {
            traits := TrieSet.put(traits, trait, Trait.hash(trait), Trait.equal);
        };

        let class_ = generateClass(prng);
        switch (class_) {
            case (#warrior) {
                attack += 1;
                health += 10;
            };
            case (#mage) {
                magic += 1;
                addTrait(#magical);
            };
            case (#rogue) {
                speed += 2;
                addTrait(#agile);
            };
            case (#archer) {
                speed += 1;
                addTrait(#perceptive);
            };
        };

        let race = generateRace(prng);
        switch (race) {
            case (#human) {
                health += 10;
                gold += 10;
            };
            case (#elf) {
                magic += 1;
                health -= 10;
            };
            case (#dwarf) {
                defense += 1;
                magic -= 1;
            };
            case (#halfling) {
                speed += 1;
                defense -= 1;
            };
            case (#faerie) {
                magic += 1;
                defense -= 1;
                addItem(#fairyCharm);
            };
        };
        {
            health = health;
            gold = gold;
            class_ = class_;
            race = race;
            stats = {
                attack = attack;
                defense = defense;
                speed = speed;
                magic = magic;
            };
            items = items;
            traits = traits;
        };
    };

    public func generateClass(prng : Prng) : Class {
        switch (prng.nextNat(0, 4)) {
            case (0) #warrior;
            case (1) #mage;
            case (2) #rogue;
            case (3) #archer;
            case (_) Prelude.unreachable();
        };
    };

    public func generateRace(prng : Prng) : Race {
        switch (prng.nextNat(0, 5)) {
            case (0) #human;
            case (1) #elf;
            case (2) #dwarf;
            case (3) #halfling;
            case (4) #faerie;
            case (_) Prelude.unreachable();
        };
    };
};
