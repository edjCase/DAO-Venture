import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        healingCost : Nat;
        blessingCost : Nat;
        communeCost : Nat;
    };

    public type Choice = {
        #seekHealing;
        #requestBlessing;
        #communeWithNature;
        #leave;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("seekHealing") ? #seekHealing;
            case ("requestBlessing") ? #requestBlessing;
            case ("communeWithNature") ? #communeWithNature;
            case ("leave") ? #leave;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#seekHealing or #requestBlessing or #leave) null;
            case (#communeWithNature) ? #trait(#naturalist);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#seekHealing) "Seek healing from the druids. Side effects may include turning into a tree.";
            case (#requestBlessing) "Request a druidic blessing. Warning: May attract squirrels.";
            case (#communeWithNature) "Commune with nature. Hope you speak fluent squirrel.";
            case (#leave) "Leave the sanctuary. The pollen was getting to you anyway.";
        };
    };

    public func getTitle() : Text {
        "Druidic Sanctuary";
    };

    public func getDescription() : Text = "You enter a serene grove where druids commune with nature. The trees seem to be whispering gossip.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            {
                id = "seekHealing";
                description = getChoiceDescription(#seekHealing);
            },
            {
                id = "requestBlessing";
                description = getChoiceDescription(#requestBlessing);
            },
            {
                id = "communeWithNature";
                description = getChoiceDescription(#communeWithNature);
            },
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
                outcomeProcessor.log("You stand motionless, unsure if that bush just winked at you.");
            };
            case (?choice) {
                switch (choice) {
                    case (#seekHealing) {
                        if (outcomeProcessor.removeGold(data.healingCost)) {
                            let healAmount = prng.nextNat(3, 7);
                            outcomeProcessor.log("The druids surround you, chanting in what sounds suspiciously like plant-ese. You feel rejuvenated, and slightly more photosynthetic.");
                            outcomeProcessor.heal(healAmount);
                        } else {
                            outcomeProcessor.log("The druids frown at your empty pockets. Seems Mother Nature doesn't work pro bono.");
                        };
                    };
                    case (#requestBlessing) {
                        if (outcomeProcessor.removeGold(data.blessingCost)) {
                            if (prng.nextRatio(2, 3)) {
                                outcomeProcessor.log("The druids bless you with the 'strength of oak'. You feel sturdier, and vaguely like you want to grow leaves.");
                                outcomeProcessor.upgradeStat(#defense, 1);
                            } else {
                                outcomeProcessor.log("The blessing goes slightly awry. You now have an inexplicable craving for sunlight and water.");
                            };
                        } else {
                            outcomeProcessor.log("The druids shake their heads. Apparently, 'the blessing of poverty' isn't a thing.");
                        };
                    };
                    case (#communeWithNature) {
                        if (outcomeProcessor.removeGold(data.communeCost)) {
                            if (prng.nextRatio(1, 2)) {
                                outcomeProcessor.log("You successfully commune with nature. A squirrel imparts ancient wisdom, and hands you a nut... er, herb.");
                                ignore outcomeProcessor.addItem(#herbs); // TODO already have item?
                            } else {
                                outcomeProcessor.log("Your attempt at communing results in a lengthy conversation with a sassy fern. You're not sure, but you think it just insulted your haircut.");
                            };
                        } else {
                            outcomeProcessor.log("Nature, it seems, doesn't accept I.O.U.s. The trees rustle disapprovingly at your lack of funds.");
                        };
                    };
                    case (#leave) {
                        outcomeProcessor.log("You leave the sanctuary, shaking off a few clingy vines. You could swear that oak just waved goodbye.");
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
            case (#seekHealing) 0;
            case (#requestBlessing) 1;
            case (#communeWithNature) 2;
            case (#leave) 3;
        };
    };

    public func generate(prng : Prng) : Data {
        {
            healingCost = prng.nextNat(15, 25);
            blessingCost = prng.nextNat(20, 30);
            communeCost = prng.nextNat(10, 20);
        };
    };
};
