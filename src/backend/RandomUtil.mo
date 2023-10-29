import PseudoRandomX "mo:random/PseudoRandomX";
import Blob "mo:base/Blob";
module {
    public func buildPrng(seedBlob : Blob) : {
        prng : PseudoRandomX.PseudoRandomGenerator;
        seed : Nat32;
    } {
        let seed = Blob.hash(seedBlob); // TODO Is this ok to use the hash vs raw bytes?
        {
            prng = PseudoRandomX.LinearCongruentialGenerator(seed);
            seed = seed;
        };
    };
};
