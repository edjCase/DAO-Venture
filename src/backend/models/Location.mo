import HexGrid "HexGrid";
import Scenario "Scenario";

module {
    public type Location = {
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
        kind : LocationKind;
    };

    public type LocationKind = {
        #unexplored;
        #scenario : Scenario.Scenario;
    };
};
