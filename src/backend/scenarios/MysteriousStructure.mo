import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {};

    public type Choice = {
        #skip;
        #forcefulEntry;
        #secretEntrance;
        #sacrifice;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("skip") ? #skip;
            case ("forcefulEntry") ? #forcefulEntry;
            case ("secretEntrance") ? #secretEntrance;
            case ("sacrifice") ? #sacrifice;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#skip or #forcefulEntry or #sacrifice) null;
            case (#secretEntrance) ? #trait(#perceptive);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#skip) "Ignore the structure and continue exploring elsewhere.";
            case (#forcefulEntry) "Attempt to create an opening using brute force or basic tools. Could be dangerous.";
            case (#sacrifice) "Offer a random resource or item to the structure, hoping to gain entry or unlock its secrets.";
            case (#secretEntrance) "Use the secret side entrance that was found from being so perceptive.";
        };
    };

    public func getTitle() : Text {
        "Mysterious Structure";
    };

    public func getDescription() : Text = "You encounter a pyramid-like structure with glowing runes, overgrown by vines. A sealed entrance beckons.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "skip"; description = getChoiceDescription(#skip) },
            {
                id = "forcefulEntry";
                description = getChoiceDescription(#forcefulEntry);
            },
            { id = "sacrifice"; description = getChoiceDescription(#sacrifice) },
            {
                id = "secretEntrance";
                description = getChoiceDescription(#secretEntrance);
            },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        _ : Data,
        choice : Choice,
    ) {

        func exploreTreasureRoom() {
            if (prng.nextRatio(5, 10)) {
                outcomeProcessor.log("You discover a hidden chamber containing a small amount of treasure.");
                outcomeProcessor.reward();
            } else {
                outcomeProcessor.log("You find nothing of interest inside.");
            };
        };

        func exploreStructure() {
            if (prng.nextRatio(1, 4)) {
                outcomeProcessor.log("You are ambushed by a group of hostile creatures!");
                let healthLoss = prng.nextNat(0, 5);
                switch (outcomeProcessor.takeDamage(healthLoss)) {
                    case (#alive) ();
                    case (#dead) {
                        return;
                    };
                };
            } else if (prng.nextRatio(1, 2)) {
                outcomeProcessor.log("You trigger a trap!");
                let damage = prng.nextNat(1, 3);
                switch (outcomeProcessor.takeDamage(damage)) {
                    case (#alive) ();
                    case (#dead) {
                        outcomeProcessor.log("The trap is too much for you to handle.");
                        return;
                    };
                };
            };
            exploreTreasureRoom();
        };

        switch (choice) {
            case (#secretEntrance) {
                outcomeProcessor.log("You find a hidden entrance and carefully make your way inside.");
                exploreTreasureRoom();
            };
            case (#forcefulEntry) {
                func rollForDamage() {
                    if (prng.nextRatio(1, 2)) {
                        outcomeProcessor.log("You hurt yourself trying to force into the entrance.");
                        let damage = prng.nextNat(1, 5);
                        switch (outcomeProcessor.takeDamage(damage)) {
                            case (#alive) ();
                            case (#dead) {
                                outcomeProcessor.log("You are defeated in the most embarassing way.");
                                return;
                            };
                        };
                    };
                };

                rollForDamage();
                if (prng.nextRatio(1, 2)) {
                    outcomeProcessor.log("You manage to create an opening and enter the structure.");
                    exploreStructure();
                } else {
                    outcomeProcessor.log("Your attempts to force your way inside are unsuccessful.");
                };
            };
            case (#sacrifice) {
                outcomeProcessor.log("You make an offering to the structure and allows you to enter safely.");
                exploreTreasureRoom();
            };
            case (#skip) {
                outcomeProcessor.log("You decide to leave the structure alone and continue exploring elsewhere.");
            };
        };
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        a == b;
    };

    public func hashChoice(choice : Choice) : Nat32 {
        switch (choice) {
            case (#skip) 0;
            case (#forcefulEntry) 1;
            case (#secretEntrance) 2;
            case (#sacrifice) 3;
        };
    };

    public func generate(_ : Prng) : Data {
        {};
    };

};
