import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import CharacterHandler "handlers/CharacterHandler";
import Outcome "models/Outcome";
import Scenario "models/Scenario";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public class Simulator(
        characterHandler : CharacterHandler.Handler
    ) {
        public func run(
            prng : Prng,
            scenario : Scenario.Scenario,
            choiceOrUndecided : ?Text,
        ) : Outcome.Outcome {
            let messages = Buffer.Buffer<Text>(5);
            // TODO
            {
                messages = Buffer.toArray(messages);
                choiceOrUndecided = choiceOrUndecided;
            };
        };
    };
};
