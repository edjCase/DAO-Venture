import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import GenericProposalEngine "mo:dao-proposal-engine/GenericProposalEngine";
import MysteriousStructureScenario "../scenarios/MysteriousStructure";
import Scenario "../models/Scenario";

module {
    public type StableData = {
        scenarios : [Scenario];
    };

    public type Scenario = {
        id : Nat;
        day : Nat;
        kind : ScenarioKind;
    };

    public type ScenarioKind = {
        #mysteriousStructure : ScenarioData<MysteriousStructureScenario.MetaData, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice>;
    };

    public type ScenarioData<MetaData, ProposalContent, Choice> = {
        proposal : GenericProposalEngine.Proposal<ProposalContent, Choice>;
        metaData : MetaData;
    };

    public type ScenarioChoiceKind = {
        #mysteriousStructure : MysteriousStructureScenario.Choice;
    };

    type MutableScenario = {
        id : Nat;
        day : Nat;
        kind : MutableScenarioKind;
    };

    type MutableScenarioKind = {
        #mysteriousStructure : MutableScenarioData<MysteriousStructureScenario.MetaData, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice>;
    };

    type MutableScenarioData<MetaData, ProposalContent, Choice> = {
        proposalEngine : GenericProposalEngine.ProposalEngine<ProposalContent, Choice>;
        metaData : MetaData;
    };

    public class Handler<system>(
        data : StableData
    ) {
        let scenarios = HashMap.HashMap<Nat, MutableScenario>(data.scenarios.size(), Nat.equal, Nat32.fromNat);
        for (scenario in data.scenarios.vals()) {
            scenarios.put(scenario.id, toMutableScenario<system>(scenario));
        };

        public func toStableData() : StableData {
            {
                scenarios = scenarios.vals()
                |> Iter.map(_, fromMutableScenario)
                |> Iter.toArray(_);
            };
        };

        public func start<system>(currentDay : Nat, kind : ScenarioKind) : Nat {
            let scenarioId = scenarios.size(); // TODO?
            let scenario = toMutableScenario<system>({
                id = scenarioId;
                day = currentDay;
                kind = kind;
            });
            scenarios.put(
                scenarioId,
                scenario,
            );
            scenarioId;
        };

        public func get(scenarioId : Nat) : ?Scenario {
            let ?scenario = scenarios.get(scenarioId) else return null;
            ?fromMutableScenario(scenario);
        };

        public func vote<system>(scenarioId : Nat, voterId : Principal, choice : ScenarioChoiceKind) : async* Result.Result<(), { #votingClosed; #notAuthorized; #scenarioNotFound; #invalidChoice; #alreadyVoted }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let result : Result.Result<(), GenericProposalEngine.VoteError> = switch (scenario.kind) {
                case (#mysteriousStructure(mysteriousStructure)) {
                    let #mysteriousStructure(mysteriousStructureChoice) = choice else return #err(#invalidChoice);
                    await* mysteriousStructure.proposalEngine.vote<system>(scenarioId, voterId, mysteriousStructureChoice);
                };
            };
            switch (result) {
                case (#ok) #ok;
                case (#err(#alreadyVoted)) #err(#alreadyVoted);
                case (#err(#notAuthorized)) #err(#notAuthorized);
                case (#err(#votingClosed)) #err(#votingClosed);
                case (#err(#proposalNotFound)) Debug.trap("Proposal not found for scenario: " # Nat.toText(scenarioId));
            };
        };

    };

    private func toMutableScenario<system>(scenario : Scenario) : MutableScenario {
        let kind : MutableScenarioKind = switch (scenario.kind) {
            case (#mysteriousStructure(mysteriousStructure)) #mysteriousStructure(toMutableMysteriousStructureScenario<system>(mysteriousStructure));
        };
        {
            id = scenario.id;
            day = scenario.day;
            kind = kind;
        };
    };

    private func fromMutableScenario(scenario : MutableScenario) : Scenario {
        {
            id = scenario.id;
            day = scenario.day;
            kind = switch (scenario.kind) {
                case (#mysteriousStructure(mysteriousStructure)) {
                    let ?proposal = mysteriousStructure.proposalEngine.getProposal(0) // TODO better way?
                    else Debug.trap("Proposal not found for mysterious structure scenario: " # Nat.toText(scenario.id));
                    #mysteriousStructure({
                        proposal = proposal;
                        metaData = mysteriousStructure.metaData;
                    });
                };
            };
        };
    };

    private func toMutableMysteriousStructureScenario<system>(
        mysteriousStructure : ScenarioData<MysteriousStructureScenario.MetaData, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice>
    ) : MutableScenarioData<MysteriousStructureScenario.MetaData, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice> {
        {
            metaData = mysteriousStructure.metaData;
            proposalEngine = GenericProposalEngine.ProposalEngine<system, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice>(
                {
                    proposals = [mysteriousStructure.proposal];
                    proposalDuration = null;
                    votingThreshold = #percent({
                        percent = 50;
                        quorum = ?20;
                    });
                },
                MysteriousStructureScenario.onProposalExecute,
                MysteriousStructureScenario.onProposalValidate,
                MysteriousStructureScenario.equalChoice,
                MysteriousStructureScenario.hashChoice,
            );
        };
    };
};
