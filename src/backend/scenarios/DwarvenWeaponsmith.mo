import Text "mo:base/Text";
import Int "mo:base/Int";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";
import Item "../models/Item";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {
        weapon : Weapon;
    };

    public type Weapon = {
        cost : Nat;
        item : Item.Weapon;
    };

    public type Choice = {
        #buyWeapon;
        #haggle;
        #leave;
        #dwarfNegotiate;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("buyWeapon") ? #buyWeapon;
            case ("haggle") ? #haggle;
            case ("leave") ? #leave;
            case ("dwarfNegotiate") ? #dwarfNegotiate;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#buyWeapon or #haggle or #leave) null;
            case (#dwarfNegotiate) ? #trait(#dwarf);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#buyWeapon) "Purchase a high-quality weapon.";
            case (#haggle) "Attempt to haggle for a better price.";
            case (#leave) "Leave without buying.";
            case (#dwarfNegotiate) "Have your dwarf crew member negotiate.";
        };
    };

    public func getTitle() : Text {
        "Dwarven Weaponsmith";
    };

    public func getDescription() : Text = "You encounter a surly dwarven weaponsmith, offering high-quality weapons at steep prices.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "buyWeapon"; description = getChoiceDescription(#buyWeapon) },
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
            case (#buyWeapon) {
                if (outcomeProcessor.removeGold(data.weapon.cost)) {
                    outcomeProcessor.log("You purchase a high-quality weapon for " # Int.toText(data.weapon.cost) # " gold.");
                    outcomeProcessor.addItem(data.weapon.item);
                } else {
                    outcomeProcessor.log("You don't have enough gold to afford the weapon.");
                };
            };
            case (#haggle) {
                if (prng.nextRatio(3, 10)) {
                    let discountedCost = prng.nextNat(30, 50);
                    outcomeProcessor.log("The dwarf grudgingly offers a discounted price of " # Int.toText(discountedCost) # " gold.");
                    // Offer discounted weapon logic here
                } else {
                    outcomeProcessor.log("The dwarf is offended by your haggling and refuses to sell to you.");
                };
            };
            case (#dwarfNegotiate) {
                let specialDeal = prng.nextNat(25, 40);
                outcomeProcessor.log("Your dwarf crew member negotiates a special deal: " # Int.toText(specialDeal) # " gold for a weapon.");
                // Offer special deal logic here
            };
            case (#leave) {
                outcomeProcessor.log("You leave the weaponsmith's shop without making a purchase.");
            };
        };
    };

    public func equalChoice(a : Choice, b : Choice) : Bool {
        a == b;
    };

    public func hashChoice(choice : Choice) : Nat32 {
        switch (choice) {
            case (#buyWeapon) 0;
            case (#haggle) 1;
            case (#leave) 2;
            case (#dwarfNegotiate) 3;
        };
    };

    let weaponTable : [(Weapon, Float)] = [
        ({ cost = 40; item = #axe }, 1.0),
        ({ cost = 20; item = #club }, 1.0),
    ];

    public func generate(prng : Prng) : Data {
        let weapon = prng.nextArrayElementWeighted(weaponTable);
        {
            weapon = weapon;
        };
    };
};
