import HexGrid "HexGrid";
module {
    public type WorldLocation = {
        kind : LocationKind;
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
    };

    public type LocationKind = {
        #unexplored : UnexploredLocation;
        #standard : StandardLocation;
    };

    public type UnexploredLocation = {
        currentExploration : Nat;
        explorationNeeded : Nat;
    };

    public type StandardLocation = {
        townId : ?Nat;
        resources : LocationResourceList;
    };

    public type LocationResourceList = {
        gold : GoldResourceInfo;
        wood : WoodResourceInfo;
        food : FoodResourceInfo;
        stone : StoneResourceInfo;
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
