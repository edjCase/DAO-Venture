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
        #upgradeWeapon;
        #haggle;
        #leave;
        #dwarfNegotiate;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("upgradeWeapon") ? #upgradeWeapon;
            case ("haggle") ? #haggle;
            case ("leave") ? #leave;
            case ("dwarfNegotiate") ? #dwarfNegotiate;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#upgradeWeapon or #haggle or #leave) null;
            case (#dwarfNegotiate) ? #trait(#dwarf);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#upgradeWeapon) "Upgrade your weapon (+1 damage).";
            case (#haggle) "Attempt to haggle for a better price.";
            case (#leave) "Leave without upgrading.";
            case (#dwarfNegotiate) "Have your dwarf crew member negotiate.";
        };
    };

    public func getTitle() : Text {
        "Dwarven Weaponsmith";
    };

    public func getDescription() : Text = "You encounter a surly dwarven weaponsmith, offering weapon upgrades at steep prices.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            {
                id = "upgradeWeapon";
                description = getChoiceDescription(#upgradeWeapon);
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
        choice : Choice,
    ) {
        switch (choice) {
            case (#upgradeWeapon) {
                if (outcomeProcessor.removeGold(data.upgradeCost)) {
                    outcomeProcessor.log("You upgrade your weapon for " # Int.toText(data.upgradeCost) # " gold.");
                    outcomeProcessor.upgradeWeapon(1);
                } else {
                    outcomeProcessor.log("You don't have enough gold to upgrade your weapon.");
                };
            };
            case (#haggle) {
                if (prng.nextRatio(3, 10)) {
                    let discountedCost = prng.nextNat(30, 50);
                    outcomeProcessor.log("The dwarf grudgingly offers a discounted upgrade price of " # Int.toText(discountedCost) # " gold.");
                    // Offer discounted upgrade logic here
                } else {
                    outcomeProcessor.log("The dwarf is offended by your haggling and refuses to upgrade your weapon.");
                };
            };
            case (#dwarfNegotiate) {
                let specialDeal = prng.nextNat(25, 40);
                outcomeProcessor.log("Your dwarf crew member negotiates a special deal: " # Int.toText(specialDeal) # " gold for a weapon upgrade.");
                // Offer special deal logic here
            };
            case (#leave) {
                outcomeProcessor.log("You leave the weaponsmith's shop without upgrading your weapon.");
            };
        };
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        a == b;
    };

    public func hashChoice(choice : Choice) : Nat32 {
        switch (choice) {
            case (#upgradeWeapon) 0;
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
