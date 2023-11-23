module {
    public type Offering = {
        #shuffleAndBoost;
    };
    public type OfferingMetaData = {
        name : Text;
        description : Text;
    };

    public type OfferingWithMetaData = OfferingMetaData and {
        offering : Offering;
    };

    public func hash(offering : Offering) : Nat32 = switch (offering) {
        case (#shuffleAndBoost) 0;
    };

    public func equal(a : Offering, b : Offering) : Bool = a == b;

    public func getMetaData(offering : Offering) : OfferingMetaData {
        switch (offering) {
            case (#shuffleAndBoost) {
                {
                    name = "Shuffle And Boost";
                    description = "Shuffle your team's field positions and boost your team with a random blessing.";
                };
            };
        };
    };
};
