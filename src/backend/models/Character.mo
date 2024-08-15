import Item "Item";
import Trait "Trait";
import TrieSet "mo:base/TrieSet";
module {

    public type Character = {
        health : Nat;
        gold : Nat;
        weaponLevel : Nat;
        items : TrieSet.Set<Item.Item>;
        traits : TrieSet.Set<Trait.Trait>;
    };
};
