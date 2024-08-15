import Text "mo:base/Text";
import Int "mo:base/Int";
import Prelude "mo:base/Prelude";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";
import Item "../models/Item";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        trinket : Trinket;
    };

    public type Trinket = {
        cost : Nat;
        item : Item.Item;
    };

    public type Choice = {
        #buyTrinket;
        #trade;
        #leave;
        #useCharm;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("buyTrinket") ? #buyTrinket;
            case ("trade") ? #trade;
            case ("leave") ? #leave;
            case ("useCharm") ? #useCharm;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#buyTrinket or #trade or #leave) null;
            case (#useCharm) ? #item(#fairyCharm);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#buyTrinket) "Purchase a magical trinket.";
            case (#trade) "Trade an item for fairy magic.";
            case (#leave) "Leave the market.";
            case (#useCharm) "Use a fairy charm to get better deals.";
        };
    };

    public func getTitle() : Text {
        "Fairy Market";
    };

    public func getDescription() : Text = "You stumble upon a hidden fairy market, offering magical trinkets and mysterious trades.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            {
                id = "buyTrinket";
                description = getChoiceDescription(#buyTrinket);
            },
            { id = "trade"; description = getChoiceDescription(#trade) },
            { id = "leave"; description = getChoiceDescription(#leave) },
            { id = "useCharm"; description = getChoiceDescription(#useCharm) },
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
                outcomeProcessor.log("You stand frozen, unable to decide. The faeries escort you out of the market.");
            };
            case (?choice) {
                switch (choice) {
                    case (#buyTrinket) {
                        if (outcomeProcessor.removeGold(data.trinket.cost)) {
                            outcomeProcessor.log("You purchase a mysterious trinket for " # Int.toText(data.trinket.cost) # " gold.");
                            ignore outcomeProcessor.addItem(data.trinket.item); // TODO already have item?
                        } else {
                            outcomeProcessor.log("You don't have enough gold to buy a trinket.");
                        };
                    };
                    case (#trade) {
                        if (prng.nextRatio(3, 5) and outcomeProcessor.loseRandomItem() and outcomeProcessor.addTrait(#magical)) {
                            outcomeProcessor.log("The fairies accept your trade, granting you a boon.");
                        } else {
                            outcomeProcessor.log("The fairies reject your offer, seeming offended.");
                        };
                    };
                    case (#useCharm) {
                        outcomeProcessor.log("Your fairy charm glows, granting you favor in the market.");
                        let true = outcomeProcessor.removeItem(#fairyCharm) else Prelude.unreachable(); // Checked with requirement
                        ignore outcomeProcessor.addTrait(#magical); // TODO already have trait?
                    };
                    case (#leave) {
                        outcomeProcessor.log("You leave the fairy market, the magical stalls fading behind you.");
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
            case (#buyTrinket) 0;
            case (#trade) 1;
            case (#leave) 2;
            case (#useCharm) 3;
        };
    };

    let trinketTable : [(Trinket, Float)] = [
        (
            {
                cost = 20;
                item = #herbs;
            },
            1.0,
        ),
        (
            {
                cost = 40;
                item = #echoCrystal;
            },
            0.1,
        ),
    ];

    public func generate(prng : Prng) : Data {
        let trinket = prng.nextArrayElementWeighted(trinketTable);
        {
            trinket = trinket;
        };
    };
};
