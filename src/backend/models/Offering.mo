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
        #moraleFlywheel;
        #badManagement;
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
        case (#moraleFlywheel) 9;
        case (#badManagement) 10;
    };

    public func equal(a : Offering, b : Offering) : Bool = a == b;

    public func getMetaData(offering : Offering) : OfferingMetaData {
        switch (offering) {
            // Initial config
            case (#shuffleAndBoost) {
                {
                    name = "Shuffle And Boost";
                    description = "Shuffle your team's field positions and boost your team with a random blessing.";
                };
            };
            // Initial config
            case (#offensive) {
                {
                    name = "Offensive";
                    description = "Your team's players will hit harder, don't catch very well.";
                };
            };
            // Initial config
            case (#defensive) {
                {
                    name = "Defensive";
                    description = "Your team's players will catch better, don't hit very hard.";
                };
            };
            // Initial config
            // On swing event
            case (#hittersDebt) {
                {
                    name = "Hitters debt";
                    description = "Every X swings is a guarenteed hit, but the team starts with a -Y score";
                };
            };
            // On dodge event
            case (#bubble) {
                {
                    name = "Bubble";
                    description = "Your team's players will be protected from the first tag/throw out.";
                };
            };
            // On round start event
            case (#underdog) {
                {
                    name = "Underdog";
                    description = "Boost team performance when behind, but reduce it when leading.";
                };
            };
            // Initial config
            case (#ragePitch) {
                {
                    name = "Rage Pitch";
                    description = "Your team's pitchers will throw faster, but less accurately.";
                };
            };
            // On blessing check event
            case (#pious) {
                {
                    name = "Pious";
                    description = "Your team's will have a higher chance of getting a blessing";
                };
            };
            // On match complete event
            case (#confident) {
                {
                    name = "Confident";
                    description = "Will have bonus rewards for winning";
                };
            };
            // On score event
            case (#moraleFlywheel) {
                {
                    name = "Morale Flywheel";
                    description = "If your team has made scored 3 times in a round, the team gets a boost for the rest of the game.";
                };
            };
            // On match start
            case (#badManagement) {
                {
                    name = "Bad Management";
                    description = "Your team's morale is hurt by missing management.";
                };
            };
        };
    };

};
