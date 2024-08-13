import HexGrid "HexGrid";

module {
    public type Location = {
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
        kind : LocationKind;
    };

    public type LocationKind = {
        #unexplored;
        #scenario : Nat;
    };
};
