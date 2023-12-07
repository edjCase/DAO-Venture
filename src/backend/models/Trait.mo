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
    };

    public func equal(a : Trait, b : Trait) : Bool = a == b;

    public func getMetaData(trait : Trait) : TraitMetaData = switch (trait) {
        case (#latePerfomer) {
            {
                name = "Late Perfomer";
                description = "Increased performance in the final inning of a match.";
            };
        };
        case (#unstable) {
            {
                name = "Unstable";
                description = "Each inning, random stats are increased or decreased.";
            };
        };
        case (#jackOfAllTrades) {
            {
                name = "Jack of All Trades";
                description = "Has average affinity for all positions permanently.";
            };
        };
        case (#prepared) {
            {
                name = "Prepared";
                description = "Is unaffected by weather conditions";
            };
        };
        case (#pious) {
            {
                name = "Pious";
                description = "Has a higher chance to be blessed by the gods.";
            };
        };
        case (#juggernaut) {
            {
                name = "Juggernaut";
                description = "Cannot be slowed";
            };
        };
        case (#sensitive) {
            {
                name = "Sensitive";
                description = "When blessed or cursed, the player is affected more than usual.";
            };
        };
        case (#puddleJumper) {
            {
                name = "Puddle Jumper";
                description = "Runs faster in rainy conditions";
            };
        };
    };
};
