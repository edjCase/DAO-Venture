import PseudoRandomX "mo:random/PseudoRandomX";
import Blob "mo:base/Blob";
module {
    public func buildPrng(seedBlob : Blob) : PseudoRandomX.PseudoRandomGenerator {
        let seed = Blob.hash(seedBlob); // TODO Is this ok to use the hash vs raw bytes?
        PseudoRandomX.LinearCongruentialGenerator(seed);
    };
};
