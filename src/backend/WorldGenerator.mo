import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Array "mo:base/Array";
import Prelude "mo:base/Prelude";
import Nat "mo:base/Nat";
import HexGrid "models/HexGrid";
import Location "models/Location";
import MysteriousStructure "scenarios/MysteriousStructure";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generateWorld(prng : Prng, radius : Nat) : [Location.Location] {
        let tileCount = 1 + 3 * radius * (radius + 1);
        Array.tabulate<Location.Location>(
            tileCount,
            func(i : Nat) : Location.Location = generateLocation(prng, i, false),
        );
    };

    public func generateLocation(prng : Prng, id : Nat, explored : Bool) : Location.Location {
        {
            id = id;
            coordinate = HexGrid.indexToAxialCoordinate(id);
            kind = if (explored) generateLocationKind(prng) else #unexplored;
        };
    };

    public func generateLocationKind(prng : Prng) : Location.LocationKind {
        switch (prng.nextNat(0, 1)) {
            case (0) #mysteriousStructure(MysteriousStructure.generateLocation(prng));
            case (_) Prelude.unreachable();
        };
    };
};
