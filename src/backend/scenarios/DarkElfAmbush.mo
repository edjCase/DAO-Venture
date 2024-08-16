import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {};

    public type Choice = {
        #fight;
        #negotiate;
        #retreat;
        #stealth;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("fight") ? #fight;
            case ("negotiate") ? #negotiate;
            case ("retreat") ? #retreat;
            case ("stealth") ? #stealth;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#fight or #negotiate or #retreat) null;
            case (#stealth) ? #trait(#agile);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#fight) "Stand your ground and engage the dark elves in combat.";
            case (#negotiate) "Attempt to parley with the dark elves, offering something in exchange for safe passage.";
            case (#retreat) "Try to escape from the ambush, potentially leaving behind some resources.";
            case (#stealth) "Use your agility to sneak past the dark elves without being detected.";
        };
    };

    public func getTitle() : Text {
        "Dark Elf Ambush";
    };

    public func getDescription() : Text = "A group of dark elves emerges from the shadows, weapons drawn. Their eyes gleam with malicious intent.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "fight"; description = getChoiceDescription(#fight) },
            { id = "negotiate"; description = getChoiceDescription(#negotiate) },
            { id = "retreat"; description = getChoiceDescription(#retreat) },
            { id = "stealth"; description = getChoiceDescription(#stealth) },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        _ : Data,
        choiceOrUndecided : ?Choice,
    ) {
        func elfAttack() {
            let damage = prng.nextNat(2, 6);
            if (not outcomeProcessor.takeDamage(damage)) {
                outcomeProcessor.log("You fall to the dark elves' attack.");
                return; // TODO stop the game
            };
        };

        switch (choiceOrUndecided) {
            case (null) {
                outcomeProcessor.log("You stand frozen, unable to decide. The elves attacks.");
                elfAttack();
            };
            case (?choice) {
                switch (choice) {
                    case (#fight) {
                        if (prng.nextRatio(3, 5)) {
                            outcomeProcessor.log("You successfully fend off the dark elves!");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("The dark elves overpower you.");
                            elfAttack();
                        };
                    };
                    case (#negotiate) {
                        if (prng.nextRatio(1, 2) and outcomeProcessor.loseRandomItem()) {
                            outcomeProcessor.log("The dark elves accept your offer and let you pass.");
                        } else {
                            outcomeProcessor.log("Negotiations fail, and the dark elves attack!");
                            elfAttack();
                        };
                    };
                    case (#retreat) {
                        if (prng.nextRatio(2, 3)) {
                            outcomeProcessor.log("You manage to escape.");
                        } else {
                            outcomeProcessor.log("Your retreat fails, and the dark elves catch up to you.");
                            elfAttack();
                        };
                    };
                    case (#stealth) {
                        if (prng.nextRatio(4, 5)) {
                            outcomeProcessor.log("You successfully sneak past the dark elves without being detected.");
                        } else {
                            outcomeProcessor.log("Despite your agility, the dark elves spot you.");
                            elfAttack();
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
            case (#negotiate) 1;
            case (#retreat) 2;
            case (#stealth) 3;
        };
    };

    public func generate(_ : Prng) : Data {
        {};
    };

};
