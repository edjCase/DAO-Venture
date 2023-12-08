module {

    public type MatchAura = {
        #lowGravity;
        #explodingBalls;
        #fastBallsHardHits;
        #moreBlessingsAndCurses;
        #moveBasesIn;
        #doubleOrNothing;
        #windy;
        #rainy;
        #foggy;
        #extraStrike;
    };

    public type MatchAuraMetaData = {
        name : Text;
        description : Text;
    };

    public type MatchAuraWithMetaData = MatchAuraMetaData and {
        aura : MatchAura;
    };

    public func hash(aura : MatchAura) : Nat32 = switch (aura) {
        case (#lowGravity) 0;
        case (#explodingBalls) 1;
        case (#fastBallsHardHits) 2;
        case (#moreBlessingsAndCurses) 3;
        case (#moveBasesIn) 4;
        case (#doubleOrNothing) 5;
        case (#windy) 6;
        case (#rainy) 7;
        case (#foggy) 8;
        case (#extraStrike) 9;
    };

    public func equal(a : MatchAura, b : MatchAura) : Bool = a == b;

    public func getMetaData(aura : MatchAura) : MatchAuraMetaData {
        switch (aura) {
            // Initial config change
            // AND? on hit event?
            case (#lowGravity) {
                {
                    name = "Low Gravity";
                    description = "Balls fly farther but player speed is lowered.";
                };
            };
            // On hit event
            case (#explodingBalls) {
                {
                    name = "Exploding Balls";
                    description = "Balls have a chance to explode on contact with the bat.";
                };
            };
            // On hit event
            case (#fastBallsHardHits) {
                {
                    name = "Fast Balls, Hard Hits";
                    description = "Balls are faster and fly farther when hit by the bat.";
                };
            };
            // On blessing check or initial config change?
            case (#moreBlessingsAndCurses) {
                {
                    name = "More Blessings And Curses";
                    description = "Blessings and curses are more common.";
                };
            };
            // On run event? easier to make it to base?
            case (#moveBasesIn) {
                {
                    name = "Move Bases In";
                    description = "Bases are closer together.";
                };
            };
            // On score event
            // On strike event
            case (#doubleOrNothing) {
                {
                    name = "Double Or Nothing";
                    description = "Runs count for double points, but strikeouts lose points.";
                };
            };
            // On swing event? throw event?
            case (#windy) {
                {
                    name = "Windy";
                    description = "The ball trajectory is more unpredictable.";
                };
            };
            // On run event
            case (#rainy) {
                {
                    name = "Rainy";
                    description = "Running injuries are more common.";
                };
            };
            // On catch event
            // On hit event
            case (#foggy) {
                {
                    name = "Foggy";
                    description = "Catching and hitting the ball is harder due to visibility.";
                };
            };
            // On strike event
            case (#extraStrike) {
                {
                    name = "Extra Strike";
                    description = "Players get an extra strike before getting out.";
                };
            };
        };
    };
};
