import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Character = {
        health : Nat;
        gold : Nat;
        classId : Text;
        raceId : Text;
        stats : CharacterStats;
        itemIds : TrieSet.Set<Text>;
        traitIds : TrieSet.Set<Text>;
    };

    public type Trait = {
        id : Text;
        name : Text;
        description : Text;
    };

    public type Item = {
        id : Text;
        name : Text;
        description : Text;
    };

    public type Race = {
        id : Text;
        name : Text;
        description : Text;
        effects : [Effect];
    };

    public type Class = {
        id : Text;
        name : Text;
        description : Text;
        effects : [Effect];
    };

    public type Effect = {
        #attack : Int;
        #defense : Int;
        #speed : Int;
        #magic : Int;
        #gold : Nat;
        #health : Int;
        #item : Text;
        #trait : Text;
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
