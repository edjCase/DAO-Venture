import HexGrid "HexGrid";
module {
    public type WorldLocationWithoutId = {
        townId : ?Nat;
        resources : [LocationResource];
    };

    public type WorldLocation = WorldLocationWithoutId and {
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
    };

    public type LocationResource = {
        #wood : Nat;
        #stone : Nat;
        #food : Nat;
    };
};
