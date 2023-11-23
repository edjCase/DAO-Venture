import Hash "mo:base/Hash";
module {

    public type Base = {
        #firstBase;
        #secondBase;
        #thirdBase;
        #homeBase;
    };

    public func equalBase(a : Base, b : Base) : Bool {
        a == b;
    };

    public func hashBase(location : Base) : Hash.Hash {
        switch (location) {
            case (#homeBase) 0;
            case (#firstBase) 1;
            case (#secondBase) 2;
            case (#thirdBase) 3;
        };
    };
};
