import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Weapon "entities/Weapon";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Character = {
        health : Nat;
        maxHealth : Nat;
        gold : Nat;
        classId : Text;
        raceId : Text;
        weapon : Weapon.Weapon;
        attack : Int;
        defense : Int;
        speed : Int;
        magic : Int;
        itemIds : TrieSet.Set<Text>;
        traitIds : TrieSet.Set<Text>;
    };

    public type CharacterStatKind = {
        #attack;
        #defense;
        #speed;
        #magic;
        #maxHealth;
    };

    public func toTextStatKind(kind : CharacterStatKind) : Text {
        switch (kind) {
            case (#attack) "attack";
            case (#defense) "defense";
            case (#speed) "speed";
            case (#magic) "magic";
            case (#maxHealth) "maxHealth";
        };
    };

};
