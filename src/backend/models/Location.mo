import HexGrid "HexGrid";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Prelude "mo:base/Prelude";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Location = {
        id : Nat; // TODO remove redundant id since it can be derived from the coordinate
        coordinate : HexGrid.AxialCoordinate;
        kind : LocationKind;
    };

    public type LocationKind = {
        #unexplored;
        #home;
        #scenario : Nat;
    };

    public func generateLocationKind(prng : Prng, scenarioGenerator : (Prng) -> Nat) : LocationKind {
        switch (prng.nextNat(0, 1)) {
            case (0) #scenario(scenarioGenerator(prng));
            case (_) Prelude.unreachable();
        };
    };
};
