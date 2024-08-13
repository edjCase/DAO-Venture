import Item "Item";
module {

    public type Character = {
        health : Nat;
        gold : Nat;
        items : [Item.Item];
        traits : [Trait];
    };

    public type Trait = {
        #perceptive;
    };
};
