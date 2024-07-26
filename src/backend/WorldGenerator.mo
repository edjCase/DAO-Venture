import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Array "mo:base/Array";
import World "models/World";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func generateWorld(prng : Prng) : [World.WorldLocationWithoutId] {
        Array.tabulate(
            7,
            func(_ : Nat) : World.WorldLocationWithoutId = generateLocation(prng),
        );
    };

    public func generateLocation(prng : Prng) : World.WorldLocationWithoutId {
        // TODO better procedural generation
        let getRandDifficulty = func() : Nat {
            return prng.nextNat(0, 10000);
        };

        let getRandAmount = func() : Nat {
            return prng.nextNat(0, 1000);
        };

        {
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
