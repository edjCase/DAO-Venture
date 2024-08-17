import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        upgradeCost : Nat;
        reforgeCost : Nat;
        craftCost : Nat;
    };

    public type Choice = {
        #upgrade;
        #reforge;
        #craft;
        #leave;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("upgrade") ? #upgrade;
            case ("reforge") ? #reforge;
            case ("craft") ? #craft;
            case ("leave") ? #leave;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#upgrade or #reforge or #leave) null;
            case (#craft) ? #trait(#artificer);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#upgrade) "Upgrade your equipment. 60% of the time, it works every time.";
            case (#reforge) "Reforge an item. It's like a makeover, but for swords!";
            case (#craft) "Craft a special item. Warning: May result in unexpected chicken statues.";
            case (#leave) "Leave the Mystic Forge. The heat was getting unbearable anyway.";
        };
    };

    public func getTitle() : Text {
        "Mystic Forge";
    };

    public func getDescription() : Text = "You enter a magical smithy where the hammers swing themselves and the anvils occasionally burp fire.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "upgrade"; description = getChoiceDescription(#upgrade) },
            { id = "reforge"; description = getChoiceDescription(#reforge) },
            { id = "craft"; description = getChoiceDescription(#craft) },
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
                outcomeProcessor.log("You stand frozen, mesmerized by the dancing flames and floating hammers.");
            };
            case (?choice) {
                switch (choice) {
                    case (#upgrade) {
                        if (outcomeProcessor.removeGold(data.upgradeCost)) {
                            if (prng.nextRatio(3, 5)) {
                                outcomeProcessor.log("The forge bellows with approval. Your equipment feels more... equipment-y.");
                                outcomeProcessor.upgradeStat(#attack, 1);
                                outcomeProcessor.upgradeStat(#defense, 1);
                            } else {
                                outcomeProcessor.log("The forge hiccups. Your gold vanishes, leaving behind a faint smell of burnt toast.");
                            };
                        } else {
                            outcomeProcessor.log("The forge eyes your empty pockets and sighs dramatically.");
                        };
                    };
                    case (#reforge) {
                        if (outcomeProcessor.removeGold(data.reforgeCost)) {
                            let stat = if (prng.nextRatio(1, 2)) #attack else #defense;
                            outcomeProcessor.log("Your item emerges from the forge, looking suspiciously similar but feeling somehow different.");
                            outcomeProcessor.upgradeStat(stat, 1);
                        } else {
                            outcomeProcessor.log("The forge snorts derisively at your lack of funds. Even magical anvils have bills to pay.");
                        };
                    };
                    case (#craft) {
                        if (outcomeProcessor.removeGold(data.craftCost)) {
                            if (prng.nextRatio(2, 3)) {
                                outcomeProcessor.log("The forge erupts in a shower of sparks. You've created something... interesting.");
                                ignore outcomeProcessor.addItem(#echoCrystal); // TODO already have item?
                            } else {
                                outcomeProcessor.log("The forge burps loudly. Your gold is gone, and you're left holding... is that a rubber chicken?");
                            };
                        } else {
                            outcomeProcessor.log("The forge grumbles about 'in this economy' and 'the cost of phoenix feathers these days'.");
                        };
                    };
                    case (#leave) {
                        outcomeProcessor.log("You leave the Mystic Forge, your eyebrows slightly singed but your spirit unquenched.");
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
            case (#upgrade) 0;
            case (#reforge) 1;
            case (#craft) 2;
            case (#leave) 3;
        };
    };

    public func generate(prng : Prng) : Data {
        {
            upgradeCost = prng.nextNat(20, 30);
            reforgeCost = prng.nextNat(15, 25);
            craftCost = prng.nextNat(25, 35);
        };
    };
};
