import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Weapon "Weapon";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Character = {
        health : Nat;
        gold : Nat;
        classId : Text;
        raceId : Text;
        weapon : Weapon.Weapon;
        stats : CharacterStats;
        itemIds : TrieSet.Set<Text>;
        traitIds : TrieSet.Set<Text>;
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

};
