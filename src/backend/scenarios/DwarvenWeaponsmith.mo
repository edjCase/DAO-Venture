import Text "mo:base/Text";
import Int "mo:base/Int";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        upgradeCost : Nat;
    };

    public type Choice = {
        #upgradeAttack;
        #haggle;
        #leave;
        #dwarfNegotiate;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("upgradeAttack") ? #upgradeAttack;
            case ("haggle") ? #haggle;
            case ("leave") ? #leave;
            case ("dwarfNegotiate") ? #dwarfNegotiate;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#upgradeAttack or #haggle or #leave) null;
            case (#dwarfNegotiate) ? #trait(#dwarf);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#upgradeAttack) "Upgrade your attack (+1).";
            case (#haggle) "Attempt to haggle for a better price.";
            case (#leave) "Leave without upgrading.";
            case (#dwarfNegotiate) "Have your dwarf crew member negotiate.";
        };
    };

    public func getTitle() : Text {
        "Dwarven Weaponsmith";
    };

    public func getDescription() : Text = "You encounter a surly dwarven weaponsmith, attack upgrades at steep prices.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            {
                id = "upgradeAttack";
                description = getChoiceDescription(#upgradeAttack);
            },
            { id = "haggle"; description = getChoiceDescription(#haggle) },
            { id = "leave"; description = getChoiceDescription(#leave) },
            {
                id = "dwarfNegotiate";
                description = getChoiceDescription(#dwarfNegotiate);
            },
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
                outcomeProcessor.log("You stand frozen, unable to decide. The dwarf pushes you out of his shop.");
            };
            case (?choice) {
                switch (choice) {
                    case (#upgradeAttack) {
                        if (outcomeProcessor.removeGold(data.upgradeCost)) {
                            outcomeProcessor.log("You upgrade your attack by 1 for " # Int.toText(data.upgradeCost) # " gold.");
                            outcomeProcessor.upgradeStat(#attack, 1);
                        } else {
                            outcomeProcessor.log("You don't have enough gold to upgrade your attack.");
                        };
                    };
                    case (#haggle) {
                        if (prng.nextRatio(3, 10)) {
                            let discountedCost = prng.nextNat(30, 50);
                            outcomeProcessor.log("The dwarf grudgingly offers a discounted upgrade price of " # Int.toText(discountedCost) # " gold.");
                            // Offer discounted upgrade logic here
                        } else {
                            outcomeProcessor.log("The dwarf is offended by your haggling and refuses to upgrade your attack.");
                        };
                    };
                    case (#dwarfNegotiate) {
                        let specialDeal = prng.nextNat(25, 40);
                        outcomeProcessor.log("Your dwarf crew member negotiates a special deal: " # Int.toText(specialDeal) # " gold for a weapon upgrade.");
                        // Offer special deal logic here
                    };
                    case (#leave) {
                        outcomeProcessor.log("You leave the weaponsmith's shop without upgrading your attack.");
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
            case (#upgradeAttack) 0;
            case (#haggle) 1;
            case (#leave) 2;
            case (#dwarfNegotiate) 3;
        };
    };

    public func generate(prng : Prng) : Data {
        {
            upgradeCost = prng.nextNat(20, 40);
        };
    };
};
