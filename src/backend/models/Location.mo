import HexGrid "HexGrid";
import MysteriousStructure "../scenarios/MysteriousStructure";
module {
    public type Location = {
        kind : LocationKind;
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
    };

    public type LocationKind = {
        #unexplored;
        #mysteriousStructure : MysteriousStructure.LocationData;
    };
};
