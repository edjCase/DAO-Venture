import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        studyCost : Nat;
        skillCost : Nat;
        mapCost : Nat;
    };

    public type Choice = {
        #study;
        #learnSkill;
        #decipherMap;
        #leave;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("study") ? #study;
            case ("learnSkill") ? #learnSkill;
            case ("decipherMap") ? #decipherMap;
            case ("leave") ? #leave;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#study or #decipherMap or #leave) null;
            case (#learnSkill) ? #trait(#clever);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#study) "Study ancient texts to increase your magic stat (costs gold).";
            case (#learnSkill) "Learn a new skill to increase your attack or defense (costs gold).";
            case (#decipherMap) "Decipher an old map for a chance to discover a hidden location (costs gold).";
            case (#leave) "Leave the Knowledge Nexus.";
        };
    };

    public func getTitle() : Text {
        "Knowledge Nexus";
    };

    public func getDescription() : Text = "You enter a floating library of ancient wisdom.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "study"; description = getChoiceDescription(#study) },
            {
                id = "learnSkill";
                description = getChoiceDescription(#learnSkill);
            },
            {
                id = "decipherMap";
                description = getChoiceDescription(#decipherMap);
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
                outcomeProcessor.log("You're overwhelmed by the vast knowledge surrounding you, unable to decide what to do.");
            };
            case (?choice) {
                switch (choice) {
                    case (#study) {
                        if (outcomeProcessor.removeGold(data.studyCost)) {
                            outcomeProcessor.log("You study ancient texts and feel your magical knowledge expand.");
                            outcomeProcessor.upgradeStat(#magic, 1);
                        } else {
                            outcomeProcessor.log("You don't have enough gold to access the rare texts.");
                        };
                    };
                    case (#learnSkill) {
                        if (outcomeProcessor.removeGold(data.skillCost)) {
                            if (prng.nextRatio(1, 2)) {
                                outcomeProcessor.log("You learn combat techniques from ancient scrolls.");
                                outcomeProcessor.upgradeStat(#attack, 1);
                            } else {
                                outcomeProcessor.log("You study defensive strategies from old tomes.");
                                outcomeProcessor.upgradeStat(#defense, 1);
                            };
                        } else {
                            outcomeProcessor.log("You don't have enough gold to learn a new skill.");
                        };
                    };
                    case (#decipherMap) {
                        if (outcomeProcessor.removeGold(data.mapCost)) {
                            if (prng.nextRatio(1, 3)) {
                                outcomeProcessor.log("You successfully decipher an ancient map, revealing a hidden location.");
                                ignore outcomeProcessor.addItem(#treasureMap); // TODO already have item?
                            } else {
                                outcomeProcessor.log("Despite your efforts, you fail to decipher the map completely.");
                            };
                        } else {
                            outcomeProcessor.log("You don't have enough gold to access the map archives.");
                        };
                    };
                    case (#leave) {
                        outcomeProcessor.log("You leave the Knowledge Nexus, your mind brimming with new information.");
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
            case (#study) 0;
            case (#learnSkill) 1;
            case (#decipherMap) 2;
            case (#leave) 3;
        };
    };

    public func generate(prng : Prng) : Data {
        {
            studyCost = prng.nextNat(10, 20);
            skillCost = prng.nextNat(15, 25);
            mapCost = prng.nextNat(20, 30);
        };
    };
};
