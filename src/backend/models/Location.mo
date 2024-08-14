import HexGrid "HexGrid";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Prelude "mo:base/Prelude";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Location = {
        id : Nat; // TODO remove redundant id since it can be derived from the coordinate
        coordinate : HexGrid.AxialCoordinate;
        scenarioId : Nat;
    };

};
