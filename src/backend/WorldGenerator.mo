import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Array "mo:base/Array";
import Prelude "mo:base/Prelude";
import Nat "mo:base/Nat";
import World "models/World";
import HexGrid "models/HexGrid";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generateWorld(prng : Prng, radius : Nat) : [World.WorldLocation] {
        let tileCount = 1 + 3 * radius * (radius + 1);
        Array.tabulate<World.WorldLocation>(
            tileCount,
            func(i : Nat) : World.WorldLocation = generateLocation(prng, i, false),
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
            let getRandomRarity = func() : World.ResourceRarity {
                prng.nextArrayElementWeighted([(#common, 1.0), (#uncommon, 0.1), (#rare, 0.01)]);
            };
            // TODO other types?
            let kind : World.ResourceKind = switch (prng.nextNat(0, 4)) {
                case (0) #wood;
                case (1) #food;
                case (2) #gold;
                case (3) #stone;
                case (_) Prelude.unreachable();
            };
            #resource({
                kind = kind;
                rarity = getRandomRarity();
            });
        } else {
            #unexplored;
        };

        kind;
    };
};
