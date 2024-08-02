import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Array "mo:base/Array";
import Prelude "mo:base/Prelude";
import Nat "mo:base/Nat";
import World "models/World";
import HexGrid "models/HexGrid";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generateWorld(prng : Prng) : [World.WorldLocation] {
        Array.tabulate<World.WorldLocation>(
            37,
            func(i : Nat) : World.WorldLocation = generateLocation(prng, i, i <= 18),
        );
    };

    public func generateLocation(prng : Prng, id : Nat, explored : Bool) : World.WorldLocation {
        {
            id = id;
            coordinate = HexGrid.indexToAxialCoordinate(id);
            kind = generateLocationKind(prng, id, explored);
        };
    };

    public func generateLocationKind(prng : Prng, _ : Nat, explored : Bool) : World.LocationKind {
        // TODO better procedural generation
        let kind : World.LocationKind = if (explored) {
            let a = prng.nextNat(0, 4);
            // TODO other types?
            switch (a) {
                case (0) #wood({ amount = prng.nextNat(0, 1000) });
                case (1) #food({ amount = prng.nextNat(0, 1000) });
                case (2) #gold({ efficiency = prng.nextFloat(0, 1) });
                case (3) #stone({ efficiency = prng.nextFloat(0, 1) });
                case (_) Prelude.unreachable();
            };
        } else {
            #unexplored({
                currentExploration = 0;
                explorationNeeded = 100;
            });
        };

        kind;
    };
};
