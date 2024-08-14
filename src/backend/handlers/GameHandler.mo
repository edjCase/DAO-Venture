import WorldHandler "WorldHandler";
import ScenarioHandler "ScenarioHandler";
import CharacterHandler "CharacterHandler";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Location "../models/Location";
import Scenario "../models/Scenario";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        world : WorldHandler.StableData;
        scenarios : ScenarioHandler.StableData;
        character : CharacterHandler.StableData;
    };

    public type WorldInfo = {
        turn : Nat;
        locations : [Location.Location];
        characterLocationId : Nat;
    };

    public class Handler<system>(data : StableData, canisterId : Principal) {

        let world = WorldHandler.Handler(data.world);
        let character = CharacterHandler.Handler(data.character);
        let scenarios = ScenarioHandler.Handler<system>(data.scenarios, character);

        public func toStableData() : StableData {
            {
                world = world.toStableData();
                scenarios = scenarios.toStableData();
                character = character.toStableData();
            };
        };

        public func nextTurn(prng : Prng, members : [ScenarioHandler.Member]) {
            switch (scenarios.end(prng, world.getCharacterLocation().scenarioId)) {
                case (#ok) ();
                case (#err(error)) Debug.trap("Unable to end scenario: " # debug_show (error));
            };

            let newScenarioId = scenarios.generateAndStart(prng, canisterId, members);
            world.nextTurn(newScenarioId);
        };

        public func getScenario(scenarioId : Nat) : ?Scenario.Scenario {
            scenarios.get(scenarioId);
        };

        public func vote(scenarioId : Nat, voterId : Principal, choice : Text) : Result.Result<(), ScenarioHandler.VoteError> {
            scenarios.vote(scenarioId, voterId, choice);
        };

        public func getVote(scenarioId : Nat, voterId : Principal) : ScenarioHandler.GetVoteResult {
            scenarios.getVote(scenarioId, voterId);
        };

        public func getVoteSummary(scenarioId : Nat) : ScenarioHandler.GetVoteSummaryResult {
            scenarios.getVoteSummary(scenarioId);
        };

        public func getWorld() : WorldInfo {
            {
                turn = world.getTurn();
                locations = world.getLocations();
                characterLocationId = world.getCharacterLocation().id;
            };
        };

    };
};
