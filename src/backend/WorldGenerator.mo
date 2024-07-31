import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Array "mo:base/Array";
import World "models/World";
import HexGrid "models/HexGrid";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generateWorld(prng : Prng) : [World.WorldLocation] {
        Array.tabulate<World.WorldLocation>(
            19,
            func(i : Nat) : World.WorldLocation = generateLocation(prng, i, i <= 6),
        );
    };

    public func generateLocation(prng : Prng, id : Nat, explored : Bool) : World.WorldLocation {
        {
            id = id;
            coordinate = HexGrid.indexToAxialCoordinate(id);
            kind = generateLocationKind(prng, id, explored);
        };
    };

    public func generateLocationKind(prng : Prng, id : Nat, explored : Bool) : World.LocationKind {
        // TODO better procedural generation
        let getRandDifficulty = func() : Nat {
            return prng.nextNat(0, 10000);
        };

        let getRandAmount = func() : Nat {
            return prng.nextNat(0, 1000);
        };
        let kind = if (explored) {
            // TODO other types?
            #standard({
                townId = null;
                resources = {
                    gold = { difficulty = getRandDifficulty() };
                    wood = { amount = getRandAmount() };
                    food = { amount = getRandAmount() };
                    stone = { difficulty = getRandDifficulty() };
                };
            });
        } else {
            #unexplored({
                currentExploration = 0;
                explorationNeeded = 100;
            });
        };

        kind;
    };
};
