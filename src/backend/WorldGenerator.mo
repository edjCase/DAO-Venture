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

    public func generateLocationKind(prng : Prng, _ : Nat, explored : Bool) : World.LocationKind {
        // TODO better procedural generation
        let getRandEfficiency = func() : Float {
            return prng.nextFloat(0, 1);
        };

        let getRandAmount = func(min : Nat, max : Nat) : Nat {
            return prng.nextNat(min, max);
        };
        let kind : World.LocationKind = if (explored) {
            // TODO other types?
            #standard({
                townId = null;
                resources = {
                    gold = { efficiency = getRandEfficiency() };
                    wood = { amount = getRandAmount(0, 1000) };
                    food = { amount = getRandAmount(0, 1000) };
                    stone = { efficiency = getRandEfficiency() };
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
