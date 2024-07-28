import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Array "mo:base/Array";
import World "models/World";
import HexGrid "models/HexGrid";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generateWorld(prng : Prng) : [World.WorldLocation] {
        Array.tabulate<World.WorldLocation>(
            7,
            func(i : Nat) : World.WorldLocation = generateLocation(prng, i),
        );
    };

    public func generateLocation(prng : Prng, id : Nat) : World.WorldLocation {
        // TODO better procedural generation
        let getRandDifficulty = func() : Nat {
            return prng.nextNat(0, 10000);
        };

        let getRandAmount = func() : Nat {
            return prng.nextNat(0, 1000);
        };

        {
            id = id;
            coordinate = HexGrid.indexToAxialCoordinate(id);
            townId = null;
            resources = {
                gold = { difficulty = getRandDifficulty() };
                wood = { amount = getRandAmount() };
                food = { amount = getRandAmount() };
                stone = { difficulty = getRandDifficulty() };
            };
        };
    };
};
