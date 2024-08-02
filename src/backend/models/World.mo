import HexGrid "HexGrid";
module {
    public type WorldLocation = {
        kind : LocationKind;
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
    };

    public type ResourceLocationKind = {
        #gold : GoldResourceInfo;
        #wood : WoodResourceInfo;
        #food : FoodResourceInfo;
        #stone : StoneResourceInfo;
    };

    public type LocationKind = ResourceLocationKind or {
        #unexplored : UnexploredLocation;
        #town : TownLocation;
    };

    public type UnexploredLocation = {
        currentExploration : Nat;
        explorationNeeded : Nat;
    };

    public type TownLocation = {
        townId : Nat;
    };

    public type GoldResourceInfo = {
        efficiency : Float;
    };

    public type WoodResourceInfo = {
        amount : Nat;
    };

    public type FoodResourceInfo = {
        amount : Nat;
    };

    public type StoneResourceInfo = {
        efficiency : Float;
    };

    public type ResourceKind = {
        #gold;
        #wood;
        #food;
        #stone;
    };
};
