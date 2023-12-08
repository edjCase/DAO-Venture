module {
    public type Trait = {
        #latePerfomer;
        #unstable;
        #jackOfAllTrades;
        #prepared;
        #pious;
        #juggernaut;
        #sensitive;
        #puddleJumper;
        #powerHitter;
        #inspiring;
        #madeOfGlass;
    };

    public type TraitMetaData = {
        name : Text;
        description : Text;
    };

    public func hash(trait : Trait) : Nat32 = switch (trait) {
        case (#latePerfomer) 0;
        case (#unstable) 1;
        case (#jackOfAllTrades) 2;
        case (#prepared) 3;
        case (#pious) 4;
        case (#juggernaut) 5;
        case (#sensitive) 6;
        case (#puddleJumper) 7;
        case (#powerHitter) 8;
        case (#inspiring) 9;
        case (#madeOfGlass) 10;
    };

    public func equal(a : Trait, b : Trait) : Bool = a == b;

    public func getMetaData(trait : Trait) : TraitMetaData = switch (trait) {
        // On round start event
        case (#latePerfomer) {
            {
                name = "Late Perfomer";
                description = "Increased performance in the final inning of a match.";
            };
        };
        // On round start event
        case (#unstable) {
            {
                name = "Unstable";
                description = "Each inning, random stats are increased or decreased.";
            };
        };
        // On affinity check event? or init event
        case (#jackOfAllTrades) {
            {
                name = "Jack of All Trades";
                description = "Has average affinity for all positions permanently.";
            };
        };
        // ?? When is weather taken into account? init?
        case (#prepared) {
            {
                name = "Prepared";
                description = "Is unaffected by weather conditions";
            };
        };
        // On blessing event
        case (#pious) {
            {
                name = "Pious";
                description = "Has a higher chance to be blessed by the gods.";
            };
        };
        // On run event?
        case (#juggernaut) {
            {
                name = "Juggernaut";
                description = "Cannot be slowed";
            };
        };
        // On blessing event
        case (#sensitive) {
            {
                name = "Sensitive";
                description = "When blessed or cursed, the player is affected more than usual.";
            };
        };
        // On run event? or init?
        case (#puddleJumper) {
            {
                name = "Puddle Jumper";
                description = "Runs faster in rainy conditions";
            };
        };
        // On hit event
        // On swing event
        case (#powerHitter) {
            {
                name = "Power Hitter";
                description = "Hits more home runs, but strikes out more often.";
            };
        };
        // On swing event
        case (#inspiring) {
            {
                name = "Inspiring";
                description = "When on base, the players at bat have a higher chance to hit.";
            };
        };
        // On throw/hit event?
        case (#madeOfGlass) {
            {
                name = "Made of Glass";
                description = "Has a higher chance to be injured.";
            };
        };
    };
};
