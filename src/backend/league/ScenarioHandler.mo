import Scenario "../models/Scenario";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";

module {
    public type Data = {
        scenarios : [ScenarioVariant];
    };

    public type ScenarioVariant = {
        #unresolved : Scenario.Scenario;
        #resolved : Scenario.ResolvedScenario;
    };

    public class Handler(data : Data) {
        let scenarios : HashMap.HashMap<Text, ScenarioVariant> = toHashMap(data.scenarios);
    };

    public func toHashMap(scenarios : [ScenarioVariant]) : HashMap.HashMap<Text, ScenarioVariant> {
        let result : HashMap.HashMap<Text, ScenarioVariant> = scenarios
        |> Iter.fromArray(_)
        |> Iter.map<ScenarioVariant, (Text, ScenarioVariant)>(
            _,
            func(scenario : ScenarioVariant) : (Text, ScenarioVariant) = switch (scenario) {
                case (#unresolved(u)) (u.id, #unresolved(u));
                case (#resolved(r)) (r.id, #resolved(r));
            },
        )
        |> HashMap.fromIter<Text, ScenarioVariant>(_, scenarios.size(), Text.equal, Text.hash);

    };
};
