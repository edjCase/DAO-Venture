import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {};

    public type Choice = {
        #attack;
        #purify;
        #evade;
        #communicate;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("attack") ? #attack;
            case ("purify") ? #purify;
            case ("evade") ? #evade;
            case ("communicate") ? #communicate;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#attack or #evade) null;
            case (#purify) ? #trait(#magical);
            case (#communicate) ? #trait(#naturalist);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#attack) "Engage the corrupted treant in combat.";
            case (#purify) "Attempt to cleanse the corruption using magic.";
            case (#evade) "Try to find a way around the treant without confrontation.";
            case (#communicate) "Use your ability to speak with nature to reason with the treant.";
        };
    };

    public func getTitle() : Text {
        "Corrupted Treant";
    };

    public func getDescription() : Text = "A massive, twisted tree creature blocks your path. Dark energy pulses through its bark.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "attack"; description = getChoiceDescription(#attack) },
            { id = "purify"; description = getChoiceDescription(#purify) },
            { id = "evade"; description = getChoiceDescription(#evade) },
            {
                id = "communicate";
                description = getChoiceDescription(#communicate);
            },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        _ : Data,
        choiceOrUndecided : ?Choice,
    ) {
        func treantAttack() {
            let damage = prng.nextNat(3, 7);
            switch (outcomeProcessor.takeDamage(damage)) {
                case (#alive) ();
                case (#dead) {
                    outcomeProcessor.log("You fall to the corrupted treant's might.");
                    return;
                };
            };
        };

        switch (choiceOrUndecided) {
            case (null) {
                outcomeProcessor.log("You stand frozen, unable to decide. The treant attacks.");
                treantAttack();
            };
            case (?choice) {
                switch (choice) {
                    case (#attack) {
                        if (prng.nextRatio(2, 5)) {
                            outcomeProcessor.log("You attack the treant, but at a reciprocates.");
                            treantAttack();
                            outcomeProcessor.reward();
                        } else {};
                    };
                    case (#purify) {
                        if (prng.nextRatio(4, 5)) {
                            outcomeProcessor.log("Your magic cleanses the corruption. The treant returns to its peaceful state.");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("The corruption resists your magic and lashes out!");
                            treantAttack();
                        };
                    };
                    case (#evade) {
                        if (prng.nextRatio(3, 5)) {
                            outcomeProcessor.log("You successfully navigate around the treant without incident.");
                        } else {
                            outcomeProcessor.log("The treant notices your attempt to sneak by and attacks!");
                            treantAttack();
                        };
                    };
                    case (#communicate) {
                        if (prng.nextRatio(4, 5)) {
                            outcomeProcessor.log("You reach the treant's consciousness. It calms and allows you to pass.");
                            outcomeProcessor.reward();
                        } else {
                            outcomeProcessor.log("The corruption is too strong. The treant attacks despite your efforts.");
                            treantAttack();
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
            case (#attack) 0;
            case (#purify) 1;
            case (#evade) 2;
            case (#communicate) 3;
        };
    };

    public func generate(_ : Prng) : Data {
        {};
    };
};
