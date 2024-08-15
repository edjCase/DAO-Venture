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
        #alchemist;
    };

    public func toId(item : Trait) : Text {
        switch (item) {
            case (#perceptive) "perceptive";
            case (#naturalist) "naturalist";
            case (#magical) "magical";
            case (#agile) "agile";
            case (#dwarf) "dwarf";
            case (#strong) "strong";
            case (#clever) "clever";
            case (#intelligent) "intelligent";
            case (#alchemist) "alchemist";
        };
    };

    public func toText(item : Trait) : Text {
        switch (item) {
            case (#perceptive) "Perceptive";
            case (#naturalist) "Naturalist";
            case (#magical) "Magical";
            case (#agile) "Agile";
            case (#dwarf) "Dwarf";
            case (#strong) "Strong";
            case (#clever) "Clever";
            case (#intelligent) "Intelligent";
            case (#alchemist) "Alchemist";
        };
    };

    public func toDescription(item : Trait) : Text {
        switch (item) {
            case (#perceptive) "You seem to pick up on things that others miss.";
            case (#naturalist) "You have a deep connection to the natural world.";
            case (#magical) "You have a natural affinity for magic.";
            case (#agile) "You are quick and nimble.";
            case (#dwarf) "You are short and stout.";
            case (#strong) "You are physically powerful.";
            case (#clever) "You are quick-witted and resourceful.";
            case (#intelligent) "You are highly intelligent.";
            case (#alchemist) "You have a deep understanding of alchemy.";
        };
    };

    public func hash(item : Trait) : Nat32 {
        switch (item) {
            case (#perceptive) 0;
            case (#naturalist) 1;
            case (#magical) 2;
            case (#agile) 3;
            case (#dwarf) 4;
            case (#strong) 5;
            case (#clever) 6;
            case (#intelligent) 7;
            case (#alchemist) 8;
        };
    };

    public func equal(a : Trait, b : Trait) : Bool {
        a == b;
    };
};
