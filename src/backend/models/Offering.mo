module {
    public type Offering = {
        #shuffleAndBoost;
        #offensive;
        #defensive;
        #hittersDebt;
        #bubble;
        #underdog;
        #ragePitch;
        #pious;
        #confident;
        #weatherControl;
        #moraleFlywheel;
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
        case (#offensive) 1;
        case (#defensive) 2;
        case (#hittersDebt) 3;
        case (#bubble) 4;
        case (#underdog) 5;
        case (#ragePitch) 6;
        case (#pious) 7;
        case (#confident) 8;
        case (#weatherControl) 9;
        case (#moraleFlywheel) 10;
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
            case (#offensive) {
                {
                    name = "Offensive";
                    description = "Your team's players will hit harder, don't catch very well.";
                };
            };
            case (#defensive) {
                {
                    name = "Defensive";
                    description = "Your team's players will catch better, don't hit very hard.";
                };
            };
            case (#hittersDebt) {
                {
                    name = "Hitters debt";
                    description = "Every X swings is a guarenteed hit, but the team starts with a -Y score";
                };
            };
            case (#bubble) {
                {
                    name = "Bubble";
                    description = "Your team's players will be protected from the first tag/throw out.";
                };
            };
            case (#underdog) {
                {
                    name = "Underdog";
                    description = "Boost team performance when behind, but reduce it when leading.";
                };
            };
            case (#ragePitch) {
                {
                    name = "Rage Pitch";
                    description = "Your team's pitchers will throw faster, but less accurately.";
                };
            };
            case (#pious) {
                {
                    name = "Pious";
                    description = "Your team's will have a higher chance of getting a blessing";
                };
            };
            case (#confident) {
                {
                    name = "Confident";
                    description = "Will have bonus rewards for winning";
                };
            };
            case (#weatherControl) {
                {
                    name = "Weather Control";
                    description = "Higher chance of weather affect occuring when at bat";
                };
            };
            case (#moraleFlywheel) {
                {
                    name = "Morale Flywheel";
                    description = "If your team has made 2+ runs in a round, batting power is increased for the round for your team.";
                };
            };
        };
    };
};
