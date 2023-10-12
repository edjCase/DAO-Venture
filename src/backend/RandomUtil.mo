import Random "mo:base/Random";
import Int "mo:base/Int";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";

module {

    public func randomInt(random : Random.Finite, min : Int, max : Int) : ?Int {
        if (min > max) {
            Debug.trap("Min cannot be larger than max");
        };
        let range : Nat = Int.abs(max - min) + 1;

        var bitsNeeded : Nat = 0;
        var temp : Nat = range;
        while (temp > 0) {
            temp := temp / 2;
            bitsNeeded += 1;
        };

        let ?randVal = random.range(Nat8.fromNat(bitsNeeded)) else return null;
        let randInt = min + (randVal % range);
        ?randInt;
    };

    public func randomNat(random : Random.Finite, min : Nat, max : Nat) : ?Nat {
        let ?randInt = randomInt(random, min, max) else return null;
        ?Int.abs(randInt);
    };
};
