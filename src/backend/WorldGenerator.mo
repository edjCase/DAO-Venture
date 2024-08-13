import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Array "mo:base/Array";
import Prelude "mo:base/Prelude";
import Nat "mo:base/Nat";
import HexGrid "models/HexGrid";
import Location "models/Location";
import Scenario "models/Scenario";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generateWorld(radius : Nat) : [Location.Location] {
        let tileCount = 1 + 3 * radius * (radius + 1);
        Array.tabulate<Location.Location>(
            tileCount,
            func(i : Nat) : Location.Location = {
                id = i;
                coordinate = HexGrid.indexToAxialCoordinate(i);
                kind = #unexplored;
            },
        );
    };

    public func generateLocationKind(prng : Prng, scenarioGenerator : (Prng) -> Nat) : Location.LocationKind {
        switch (prng.nextNat(0, 1)) {
            case (0) #scenario(scenarioGenerator(prng));
            case (_) Prelude.unreachable();
        };
    };
};
