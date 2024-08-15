import Text "mo:base/Text";
import Prelude "mo:base/Prelude";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        cost : Nat;
    };

    public type Choice = {
        #tradeHerbs;
        #buyPotion;
        #learnRecipe;
        #decline;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("tradeHerbs") ? #tradeHerbs;
            case ("buyPotion") ? #buyPotion;
            case ("learnRecipe") ? #learnRecipe;
            case ("decline") ? #decline;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#tradeHerbs) ? #item(#herbs);
            case (#buyPotion) null;
            case (#learnRecipe) ? #trait(#intelligent);
            case (#decline) null;
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#tradeHerbs) "Trade your herbs for a random potion.";
            case (#buyPotion) "Buy a potion of your choice for some gold.";
            case (#learnRecipe) "Try to learn a potion recipe from the alchemist.";
            case (#decline) "Politely decline and continue on your way.";
        };
    };

    public func getTitle() : Text {
        "Wandering Alchemist";
    };

    public func getDescription() : Text = "You encounter a wandering alchemist, their pack filled with bubbling vials and aromatic herbs.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            {
                id = "tradeHerbs";
                description = getChoiceDescription(#tradeHerbs);
            },
            { id = "buyPotion"; description = getChoiceDescription(#buyPotion) },
            {
                id = "learnRecipe";
                description = getChoiceDescription(#learnRecipe);
            },
            { id = "decline"; description = getChoiceDescription(#decline) },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        data : Data,
        choice : Choice,
    ) {
        switch (choice) {
            case (#tradeHerbs) {
                outcomeProcessor.log("You trade your herbs for a mysterious potion.");
                let true = outcomeProcessor.removeItem(#herbs) else Prelude.unreachable(); // A requirement for the choice
                ignore outcomeProcessor.addItem(#healthPotion); // TODO already have item?
            };
            case (#buyPotion) {
                if (outcomeProcessor.removeGold(data.cost)) {
                    outcomeProcessor.log("You purchase a potion of your choice from the alchemist.");
                    ignore outcomeProcessor.addItem(#healthPotion); // TODO already have item?
                } else {
                    outcomeProcessor.log("You don't have enough gold to buy a potion.");
                };
            };
            case (#learnRecipe) {
                if (prng.nextRatio(3, 5)) {
                    outcomeProcessor.log("You successfully learn a new potion recipe from the alchemist!");
                    ignore outcomeProcessor.addTrait(#alchemist); // TODO already have trait?
                } else {
                    outcomeProcessor.log("The alchemist's instructions are too complex. You fail to learn the recipe.");
                };
            };
            case (#decline) {
                outcomeProcessor.log("You politely decline the alchemist's offers and continue on your journey.");
            };
        };
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        a == b;
    };

    public func hashChoice(choice : Choice) : Nat32 {
        switch (choice) {
            case (#tradeHerbs) 0;
            case (#buyPotion) 1;
            case (#learnRecipe) 2;
            case (#decline) 3;
        };
    };

    public func generate(_ : Prng) : Data {
        {
            cost = 30;
        };
    };
};
