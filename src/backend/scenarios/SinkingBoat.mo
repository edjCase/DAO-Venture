import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {};

    public type Choice = {
        #rescueSwimming;
        #castSpell;
        #disregard;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("rescueSwimming") ? #rescueSwimming;
            case ("castSpell") ? #castSpell;
            case ("disregard") ? #disregard;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#rescueSwimming or #disregard) null;
            case (#castSpell) ? #trait(#magical);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#rescueSwimming) "Swim out to rescue the passengers.";
            case (#castSpell) "Cast a water-walking spell to rescue the passengers.";
            case (#disregard) "disregard the sinking boat and continue on your way.";
        };
    };

    public func getTitle() : Text {
        "Sinking Boat";
    };

    public func getDescription() : Text = "You come across a small boat sinking in a nearby river. The passengers are calling for help.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            {
                id = "rescueSwimming";
                description = getChoiceDescription(#rescueSwimming);
            },
            { id = "castSpell"; description = getChoiceDescription(#castSpell) },
            { id = "disregard"; description = getChoiceDescription(#disregard) },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        _ : Data,
        choiceOrUndecided : ?Choice,
    ) {
        switch (choiceOrUndecided) {
            case (null) {
                outcomeProcessor.log("You dont seem to notice and carry on.");
            };
            case (?choice) {
                switch (choice) {
                    case (#rescueSwimming) {
                        if (prng.nextRatio(3, 5)) {
                            outcomeProcessor.log("You successfully swim out and rescue the passengers.");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("The current is stronger than you anticipated.");
                            let damage = prng.nextNat(1, 3);
                            switch (outcomeProcessor.takeDamage(damage)) {
                                case (#alive) {
                                    outcomeProcessor.log("You manage to rescue the passengers, but at a cost to your health.");
                                    outcomeProcessor.reward();
                                };
                                case (#dead) {
                                    outcomeProcessor.log("The river's current proves too much for you to handle.");
                                    return;
                                };
                            };
                        };
                    };
                    case (#castSpell) {
                        if (prng.nextRatio(4, 5)) {
                            outcomeProcessor.log("Your water-walking spell allows you to easily rescue all passengers.");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("Your spell falters midway through the rescue.");
                            let damage = prng.nextNat(1, 2);
                            switch (outcomeProcessor.takeDamage(damage)) {
                                case (#alive) {
                                    outcomeProcessor.log("Despite the setback, you manage to complete the rescue.");
                                    outcomeProcessor.reward();
                                };
                                case (#dead) {
                                    outcomeProcessor.log("The spell's failure leads to a tragic end for both you and the passengers.");
                                    return;
                                };
                            };
                        };
                    };
                    case (#disregard) {
                        outcomeProcessor.log("You disregard the calls for help and continue on your way, leaving the passengers to their fate.");
                    };
                };
            };
        };
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        a == b;
    };

    public func hashChoice(choice : Choice) : Nat32 {
        switch (choice) {
            case (#rescueSwimming) 0;
            case (#castSpell) 1;
            case (#disregard) 2;
        };
    };

    public func generate(_ : Prng) : Data {
        {};
    };
};
