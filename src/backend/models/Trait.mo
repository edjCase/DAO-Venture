module {

    public type Trait = {
        #perceptive;
        #naturalist;
        #magical;
        #agile;
        #dwarf;
        #strong;
        #clever;
        #intelligent;
    };

    public func toId(item : Trait) : Text {
        switch (item) {
            case (#perceptive) "perceptive";
        };
    };

    public func toText(item : Trait) : Text {
        switch (item) {
            case (#perceptive) "Perceptive";
        };
    };

    public func toDescription(item : Trait) : Text {
        switch (item) {
            case (#perceptive) "You are perceptive.";
        };
    };
};
