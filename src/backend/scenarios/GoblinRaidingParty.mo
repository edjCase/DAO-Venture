import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        bribeCost : Nat;
    };

    public type Choice = {
        #fight;
        #bribe;
        #intimidate;
        #distract;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("fight") ? #fight;
            case ("bribe") ? #bribe;
            case ("intimidate") ? #intimidate;
            case ("distract") ? #distract;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#fight or #bribe) null;
            case (#intimidate) ? #trait(#strong);
            case (#distract) ? #trait(#clever);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#fight) "Engage the goblin raiding party in combat.";
            case (#bribe) "Offer some of your resources to appease the goblins.";
            case (#intimidate) "Use your strength to scare off the goblins.";
            case (#distract) "Create a clever diversion to escape the goblins.";
        };
    };

    public func getTitle() : Text {
        "Goblin Raiding Party";
    };

    public func getDescription() : Text = "A band of goblins emerges from the underbrush, brandishing crude weapons and eyeing your possessions.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "fight"; description = getChoiceDescription(#fight) },
            { id = "bribe"; description = getChoiceDescription(#bribe) },
            {
                id = "intimidate";
                description = getChoiceDescription(#intimidate);
            },
            { id = "distract"; description = getChoiceDescription(#distract) },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        data : Data,
        choiceOrUndecided : ?Choice,
    ) {
        func goblinAttack() {
            let damage = prng.nextNat(1, 3);
            if (not outcomeProcessor.takeDamage(damage)) {
                outcomeProcessor.log("The goblin's greed knows no bounds.");
                return; // TODO stop the game
            };
        };
        switch (choiceOrUndecided) {
            case (null) {
                outcomeProcessor.log("You stand frozen, unable to decide. The dwarf pushes you out of his shop.");
            };
            case (?choice) {
                switch (choice) {
                    case (#fight) {
                        if (prng.nextRatio(3, 5)) {
                            outcomeProcessor.log("You successfully fend off the goblin raiding party!");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("The goblins overwhelm you with their numbers.");
                            goblinAttack();
                        };
                    };
                    case (#bribe) {
                        if (outcomeProcessor.removeGold(data.bribeCost)) {
                            if (prng.nextRatio(4, 5)) {
                                outcomeProcessor.log("The goblins accept your offering and leave you alone.");
                            } else {
                                outcomeProcessor.log("The goblins take your bribe but attack anyway!");
                                goblinAttack();
                            };
                        } else {
                            outcomeProcessor.log("The goblins see you don't have any gold and attack!");
                            goblinAttack();
                        };
                    };
                    case (#intimidate) {
                        if (prng.nextRatio(4, 5)) {
                            outcomeProcessor.log("Your show of strength scares off the goblins.");
                        } else {
                            outcomeProcessor.log("The goblins are not impressed and attack!");
                            goblinAttack();
                        };
                    };
                    case (#distract) {
                        if (prng.nextRatio(4, 5)) {
                            outcomeProcessor.log("Your clever diversion allows you to slip away unnoticed.");
                        } else {
                            outcomeProcessor.log("The goblins see through your trick and attack!");
                            goblinAttack();
                        };
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
            case (#fight) 0;
            case (#bribe) 1;
            case (#intimidate) 2;
            case (#distract) 3;
        };
    };

    public func generate(_ : Prng) : Data {
        {
            bribeCost = 20;
        };
    };
};
