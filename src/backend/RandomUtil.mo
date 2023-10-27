import PsuedoRandomX "mo:random/PsuedoRandomX";
import Blob "mo:base/Blob";
module {
    public func buildPrng(seedBlob : Blob) : PsuedoRandomX.PsuedoRandomGenerator {
        let seed = Blob.hash(seedBlob); // TODO Is this ok to use the hash vs raw bytes?
        PsuedoRandomX.LinearCongruentialGenerator(seed);
    };
};
