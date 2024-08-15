import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {};

    public type Choice = {
        #freeDirectly;
        #useNatureSkills;
        #findAlternativeSolution;
        #leaveAlone;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("freeDirectly") ? #freeDirectly;
            case ("useNatureSkills") ? #useNatureSkills;
            case ("findAlternativeSolution") ? #findAlternativeSolution;
            case ("leaveAlone") ? #leaveAlone;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#freeDirectly or #findAlternativeSolution or #leaveAlone) null;
            case (#useNatureSkills) ? #trait(#naturalist);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#freeDirectly) "Attempt to free the druid directly from the magical snare.";
            case (#useNatureSkills) "Use your nature-speaking abilities to communicate with the forest and find a safe way to free the druid.";
            case (#findAlternativeSolution) "Search the area for clues or tools that might help free the druid.";
            case (#leaveAlone) "Decide the situation is too risky and leave the druid to their fate.";
        };
    };

    public func getTitle() : Text {
        "Trapped Druid";
    };

    public func getDescription() : Text = "You come across a druid entangled in a strange, pulsating magical snare. They call out for help.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            {
                id = "freeDirectly";
                description = getChoiceDescription(#freeDirectly);
            },
            {
                id = "useNatureSkills";
                description = getChoiceDescription(#useNatureSkills);
            },
            {
                id = "findAlternativeSolution";
                description = getChoiceDescription(#findAlternativeSolution);
            },
            {
                id = "leaveAlone";
                description = getChoiceDescription(#leaveAlone);
            },
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
                outcomeProcessor.log("You don't seem to hear them and continue walking.");
            };
            case (?choice) {
                switch (choice) {
                    case (#freeDirectly) {
                        if (prng.nextRatio(1, 2)) {
                            outcomeProcessor.log("You successfully free the druid from the magical snare.");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("The magical snare reacts violently to your attempt.");
                            let damage = prng.nextNat(2, 4);
                            switch (outcomeProcessor.takeDamage(damage)) {
                                case (#alive) ();
                                case (#dead) {
                                    outcomeProcessor.log("The magical backlash proves fatal.");
                                    return;
                                };
                            };
                        };
                    };
                    case (#useNatureSkills) {
                        if (prng.nextRatio(4, 5)) {
                            outcomeProcessor.log("Your nature skills allow you to safely disarm the snare and free the druid.");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("Despite your skills, the snare proves too complex to disarm safely.");
                            let damage = prng.nextNat(1, 2);
                            switch (outcomeProcessor.takeDamage(damage)) {
                                case (#alive) ();
                                case (#dead) {
                                    outcomeProcessor.log("The magical snare overwhelms your abilities.");
                                    return;
                                };
                            };
                        };
                    };
                    case (#findAlternativeSolution) {
                        if (prng.nextRatio(2, 3)) {
                            outcomeProcessor.log("You find a magical artifact nearby that helps neutralize the snare.");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("Your search attracts unwanted attention from forest creatures.");
                            let damage = prng.nextNat(1, 3);
                            switch (outcomeProcessor.takeDamage(damage)) {
                                case (#alive) ();
                                case (#dead) {
                                    outcomeProcessor.log("The forest creatures prove too much to handle.");
                                    return;
                                };
                            };
                        };
                    };
                    case (#leaveAlone) {
                        outcomeProcessor.log("You decide the risk is too great and leave the druid to their fate.");
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
            case (#freeDirectly) 0;
            case (#useNatureSkills) 1;
            case (#findAlternativeSolution) 2;
            case (#leaveAlone) 3;
        };
    };

    public func generate(_ : Prng) : Data {
        {};
    };
};
