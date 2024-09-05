import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Character = {
        health : Nat;
        maxHealth : Nat;
        gold : Nat;
        classId : Text;
        raceId : Text;
        weaponId : Text;
        itemIds : TrieSet.Set<Text>;
        traitIds : TrieSet.Set<Text>;
    };
};
