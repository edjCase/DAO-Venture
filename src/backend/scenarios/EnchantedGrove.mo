import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        meditationCost : Nat;
        harvestCost : Nat;
        communeCost : Nat;
    };

    public type Choice = {
        #meditate;
        #harvest;
        #commune;
        #leave;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("meditate") ? #meditate;
            case ("harvest") ? #harvest;
            case ("commune") ? #commune;
            case ("leave") ? #leave;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#meditate or #commune or #leave) null;
            case (#harvest) ? #trait(#naturalist);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#meditate) "Meditate to increase your magic stat (costs gold).";
            case (#harvest) "Harvest rare herbs (costs health).";
            case (#commune) "Commune with nature spirits for a chance at a unique item (costs gold).";
            case (#leave) "Leave the grove.";
        };
    };

    public func getTitle() : Text {
        "Enchanted Grove";
    };

    public func getDescription() : Text = "You enter a serene grove with magical properties.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "meditate"; description = getChoiceDescription(#meditate) },
            { id = "harvest"; description = getChoiceDescription(#harvest) },
            { id = "commune"; description = getChoiceDescription(#commune) },
            { id = "leave"; description = getChoiceDescription(#leave) },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        data : Data,
        choiceOrUndecided : ?Choice,
    ) {
        switch (choiceOrUndecided) {
            case (null) {
                outcomeProcessor.log("You stand in awe of the grove's beauty, unable to decide what to do.");
            };
            case (?choice) {
                switch (choice) {
                    case (#meditate) {
                        if (outcomeProcessor.removeGold(data.meditationCost)) {
                            outcomeProcessor.log("You meditate and feel your magical abilities grow stronger.");
                            outcomeProcessor.upgradeStat(#magic, 1);
                        } else {
                            outcomeProcessor.log("You don't have enough gold to perform the meditation ritual.");
                        };
                    };
                    case (#harvest) {
                        if (outcomeProcessor.takeDamage(data.harvestCost)) {
                            outcomeProcessor.log("You harvest rare herbs from the grove, expending some energy in the process.");
                            ignore outcomeProcessor.addItem(#herbs); // TODO already have item?
                            if (prng.nextRatio(1, 2)) {
                                outcomeProcessor.log("The grove's magic rejuvenates you slightly.");
                                outcomeProcessor.heal(data.harvestCost / 2);
                            };
                        } else {
                            outcomeProcessor.log("You don't have enough health to safely harvest the herbs.");
                        };
                    };
                    case (#commune) {
                        if (outcomeProcessor.removeGold(data.communeCost)) {
                            if (prng.nextRatio(1, 3)) {
                                outcomeProcessor.log("You commune with nature spirits and receive a unique item.");
                                ignore outcomeProcessor.addItem(#fairyCharm); // TODO already have item?
                            } else {
                                outcomeProcessor.log("You commune with nature spirits but receive no tangible reward.");
                            };
                        } else {
                            outcomeProcessor.log("You don't have enough gold to commune with nature spirits.");
                        };
                    };
                    case (#leave) {
                        outcomeProcessor.log("You leave the enchanted grove, feeling refreshed.");
                        outcomeProcessor.heal(1);
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
            case (#meditate) 0;
            case (#harvest) 1;
            case (#commune) 2;
            case (#leave) 3;
        };
    };

    public func generate(prng : Prng) : Data {
        {
            meditationCost = prng.nextNat(5, 10);
            harvestCost = prng.nextNat(1, 3);
            communeCost = prng.nextNat(10, 20);
        };
    };
};
