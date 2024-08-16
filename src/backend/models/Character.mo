import Item "Item";
import Trait "Trait";
import TrieSet "mo:base/TrieSet";
module {

    public type Character = {
        health : Nat;
        gold : Nat;
        stats : CharacterStats;
        items : TrieSet.Set<Item.Item>;
        traits : TrieSet.Set<Trait.Trait>;
    };

    public type CharacterStats = {
        attack : Nat;
        defense : Nat;
        speed : Nat;
        magic : Nat;
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
