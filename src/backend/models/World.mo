import HexGrid "HexGrid";
module {
    public type WorldLocationWithoutId = {
        townId : ?Nat;
        resources : LocationResourceList;
    };

    public type WorldLocation = WorldLocationWithoutId and {
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
    };

    public type LocationResourceList = {
        gold : GoldResourceInfo;
        wood : WoodResourceInfo;
        food : FoodResourceInfo;
        stone : StoneResourceInfo;
    };

    public type GoldResourceInfo = {
        difficulty : Nat;
    };

    public type WoodResourceInfo = {
        amount : Nat;
    };

    public type FoodResourceInfo = {
        amount : Nat;
    };

    public type StoneResourceInfo = {
        difficulty : Nat;
    };

    public type ResourceKind = {
        #gold;
        #wood;
        #food;
        #stone;
    };
};