import Item "Item";
import Trait "Trait";
module {

    public type Character = {
        health : Nat;
        gold : Nat;
        items : [Item.Item];
        traits : [Trait.Trait];
    };
};
