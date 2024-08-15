import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Data = {};

    public type Choice = {
        #help;
        #abandon;
        #investigate;
        #useMagic;
    };

    public func choiceFromText(text : Text) : ?Choice {
        switch (text) {
            case ("help") ? #help;
            case ("abandon") ? #abandon;
            case ("investigate") ? #investigate;
            case ("useMagic") ? #useMagic;
            case (_) null;
        };
    };

    public func getChoiceRequirement(choice : Choice) : ?Outcome.ChoiceRequirement {
        switch (choice) {
            case (#help or #abandon or #investigate) null;
            case (#useMagic) ? #trait(#magical);
        };
    };

    public func getChoiceDescription(choice : Choice) : Text {
        switch (choice) {
            case (#help) "Offer assistance to the lost elfling.";
            case (#abandon) "Continue on your way, leaving the elfling to its fate.";
            case (#investigate) "Carefully investigate the area before approaching the elfling.";
            case (#useMagic) "Use magic to locate the elfling's clan or create a safe path.";
        };
    };

    public func getTitle() : Text {
        "Lost Elfling";
    };

    public func getDescription() : Text = "You hear the faint cries of a young elf, seemingly lost and separated from their clan.";

    public func getOptions() : [{ id : Text; description : Text }] {
        [
            { id = "help"; description = getChoiceDescription(#help) },
            { id = "abandon"; description = getChoiceDescription(#abandon) },
            {
                id = "investigate";
                description = getChoiceDescription(#investigate);
            },
            { id = "useMagic"; description = getChoiceDescription(#useMagic) },
        ];
    };

    public func processOutcome(
        prng : Prng,
        outcomeProcessor : Outcome.Processor,
        _ : Data,
        choice : Choice,
    ) {
        switch (choice) {
            case (#help) {
                if (prng.nextRatio(4, 5)) {
                    outcomeProcessor.log("You successfully help the elfling and reunite them with their clan.");
                    outcomeProcessor.reward();
                } else {
                    outcomeProcessor.log("Your attempt to help leads you into a dangerous situation.");
                    let damage = prng.nextNat(1, 3);
                    switch (outcomeProcessor.takeDamage(damage)) {
                        case (#alive) ();
                        case (#dead) {
                            outcomeProcessor.log("The forest's dangers prove too much in your rescue attempt.");
                            return;
                        };
                    };
                };
            };
            case (#abandon) {
                outcomeProcessor.log("You ignore the elfling's cries and continue on your way.");
            };
            case (#investigate) {
                if (prng.nextRatio(3, 4)) {
                    outcomeProcessor.log("Your careful investigation reveals a safe path to the elfling.");
                    outcomeProcessor.reward();
                } else {
                    outcomeProcessor.log("While investigating, you stumble into a hidden danger.");
                    let damage = prng.nextNat(1, 2);
                    switch (outcomeProcessor.takeDamage(damage)) {
                        case (#alive) ();
                        case (#dead) {
                            outcomeProcessor.log("The hidden danger proves fatal.");
                            return;
                        };
                    };
                };
            };
            case (#useMagic) {
                if (prng.nextRatio(9, 10)) {
                    outcomeProcessor.log("Your magic successfully guides the elfling back to their clan.");
                    outcomeProcessor.reward();
                } else {
                    outcomeProcessor.log("Your magic attracts unwanted attention from forest spirits.");
                    let damage = prng.nextNat(1, 2);
                    switch (outcomeProcessor.takeDamage(damage)) {
                        case (#alive) ();
                        case (#dead) {
                            outcomeProcessor.log("The forest spirits overwhelm you.");
                            return;
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
            case (#help) 0;
            case (#abandon) 1;
            case (#investigate) 2;
            case (#useMagic) 3;
        };
    };

    public func generate(_ : Prng) : Data {
        {};
    };
};
