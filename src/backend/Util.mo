import PseudoRandomX "mo:random/PseudoRandomX";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
module {
    public func buildPrng(seedBlob : Blob) : PseudoRandomX.PseudoRandomGenerator {
        let seed = Blob.hash(seedBlob); // TODO Is this ok to use the hash vs raw bytes?
        PseudoRandomX.LinearCongruentialGenerator(seed);
    };

    public type ContextWithResult<T, TResult> = {
        context : T;
        result : TResult;
    };
    public type Result<TOk, TError> = { #ok : TOk; #error : TError };
    public type AllResult<TOk, TError> = {
        #ok : [TOk];
        #error : [TError];
    };

    public func allOkOrError<TOk, TError>(
        results : Iter.Iter<Result<TOk, TError>>
    ) : AllResult<TOk, TError> {
        let okItems = Buffer.Buffer<TOk>(10);
        let errorItems = Buffer.Buffer<TError>(0);
        for (result in results) {
            switch (result) {
                case (#ok(ok)) okItems.add(ok);
                case (#error(error)) errorItems.add(error);
            };
        };
        if (errorItems.size() > 0) {
            #error(Buffer.toArray(errorItems));
        } else {
            #ok(Buffer.toArray(okItems));
        };
    };

};
