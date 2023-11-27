import PseudoRandomX "mo:random/PseudoRandomX";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
module {
    public func buildPrng(seedBlob : Blob) : PseudoRandomX.PseudoRandomGenerator {
        let seed = Blob.hash(seedBlob); // TODO Is this ok to use the hash vs raw bytes?
        PseudoRandomX.LinearCongruentialGenerator(seed);
    };

    public func arrayGetOpt<T>(array : [T], index : Nat) : ?T {
        if (index >= array.size()) {
            null;
        } else {
            ?array[index];
        };
    };

};
