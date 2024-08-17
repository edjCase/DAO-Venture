module {

    public type Trait = {
        #perceptive;
        #naturalist;
        #agile;
        #dwarf;
        #strong;
        #clever;
        #intelligent;
        #alchemist;
        #artificer;
    };

    public func toId(item : Trait) : Text {
        switch (item) {
            case (#perceptive) "perceptive";
            case (#naturalist) "naturalist";
            case (#agile) "agile";
            case (#dwarf) "dwarf";
            case (#strong) "strong";
            case (#clever) "clever";
            case (#intelligent) "intelligent";
            case (#alchemist) "alchemist";
            case (#artificer) "artificer";
        };
    };

    public func toText(item : Trait) : Text {
        switch (item) {
            case (#perceptive) "Perceptive";
            case (#naturalist) "Naturalist";
            case (#agile) "Agile";
            case (#dwarf) "Dwarf";
            case (#strong) "Strong";
            case (#clever) "Clever";
            case (#intelligent) "Intelligent";
            case (#alchemist) "Alchemist";
            case (#artificer) "Artificer";
        };
    };

    public func toDescription(trait : Trait) : Text {
        switch (trait) {
            case (#perceptive) "You can spot a needle in a haystack, especially if the needle owes you money.";
            case (#naturalist) "You're so in tune with nature, trees consider you their therapist.";
            case (#agile) "You're so nimble, you could dance through a field of mousetraps... hypothetically.";
            case (#dwarf) "You're vertically challenged but horizontally gifted. And yes, it all goes into the beard.";
            case (#strong) "You don't break a sweat, you break barbells. Doors fear your knock.";
            case (#clever) "Your wit is so sharp, it's considered a concealed weapon in seven kingdoms.";
            case (#intelligent) "Your brain is so big, it has its own gravity field. Watch out for orbiting ideas!";
            case (#alchemist) "You can turn lead into gold, but mostly you just turn gold into 'oops'.";
            case (#artificer) "Half wizard, half handyman. Your tool belt is 90% pockets, 10% interdimensional spaces.";
        };
    };

    public type State = {
        id : Text;
        name : Text;
        description : Text;
    };

    public func toState(item : Trait) : State {
        {
            id = toId(item);
            name = toText(item);
            description = toDescription(item);
        };
    };

    public func hash(item : Trait) : Nat32 {
        switch (item) {
            case (#perceptive) 0;
            case (#naturalist) 1;
            case (#agile) 2;
            case (#dwarf) 3;
            case (#strong) 4;
            case (#clever) 5;
            case (#intelligent) 6;
            case (#alchemist) 7;
            case (#artificer) 8;
        };
    };

    public func equal(a : Trait, b : Trait) : Bool {
        a == b;
    };
};
