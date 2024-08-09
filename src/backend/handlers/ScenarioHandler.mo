import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import GenericProposalEngine "mo:dao-proposal-engine/GenericProposalEngine";
import MysteriousStructureScenario "../scenarios/MysteriousStructure";
import Scenario "../models/Scenario";
import CommonTypes "../CommonTypes";
import IterTools "mo:itertools/Iter";

module {
    public type StableData = {
        scenarios : [Scenario.Scenario];
    };

    type MutableScenario = {
        id : Nat;
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

        public func start<system>(currentDay : Nat, kind : Scenario.ScenarioKind) : Nat {
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

        public func get(scenarioId : Nat) : ?Scenario.Scenario {
            let ?scenario = scenarios.get(scenarioId) else return null;
            ?fromMutableScenario(scenario);
        };

        public func getAll(count : Nat, offset : Nat) : CommonTypes.PagedResult<Scenario.Scenario> {
            var filteredScenarios = scenarios.vals()
            |> Iter.sort(
                _,
                func(a : MutableScenario, b : MutableScenario) : Order.Order = Nat.compare(a.id, b.id),
            )
            |> IterTools.skip(_, offset)
            |> IterTools.take(_, count)
            |> Iter.map(_, fromMutableScenario)
            |> Iter.toArray(_);
            {
                data = filteredScenarios;
                offset = offset;
                count = count;
                totalCount = scenarios.size();
            };
        };

        public func getVote(
            scenarioId : Nat,
            voterId : Principal,
        ) : Result.Result<GenericProposalEngine.Vote<Scenario.ScenarioChoiceKind>, { #scenarioNotFound; #notEligible }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let result : ?GenericProposalEngine.Vote<Scenario.ScenarioChoiceKind> = switch (scenario.kind) {
                case (#mysteriousStructure(mysteriousStructure)) {
                    let proposalId = 0; // TODO better way?
                    let vote = mysteriousStructure.proposalEngine.getVote(proposalId, voterId);
                    switch (vote) {
                        case (?v) {
                            let choice = switch (v.choice) {
                                case (?choice) ? #mysteriousStructure(choice);
                                case (null) null;
                            };
                            ?{
                                v with
                                choice = choice;
                            };
                        };
                        case (null) null;
                    };
                };
            };
            switch (result) {
                case (?vote) #ok(vote);
                case (null) #err(#notEligible);
            };
        };

        public func getVoteSummary(scenarioId : Nat) : Result.Result<GenericProposalEngine.VotingSummary<Scenario.ScenarioChoiceKind>, { #scenarioNotFound }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let summary : GenericProposalEngine.VotingSummary<Scenario.ScenarioChoiceKind> = switch (scenario.kind) {
                case (#mysteriousStructure(mysteriousStructure)) {
                    let proposalId = 0; // TODO better way?
                    let summary = mysteriousStructure.proposalEngine.getVoteSummary(proposalId);
                    {
                        summary with
                        votingPowerByChoice = summary.votingPowerByChoice.vals()
                        |> Iter.map(
                            _,
                            func(
                                choice : GenericProposalEngine.ChoiceVotingPower<MysteriousStructureScenario.Choice>
                            ) : GenericProposalEngine.ChoiceVotingPower<Scenario.ScenarioChoiceKind> = {
                                choice = #mysteriousStructure(choice.choice);
                                votingPower = choice.votingPower;
                            },
                        )
                        |> Iter.toArray(_);
                    };
                };
            };
            #ok(summary);
        };

        public func vote<system>(scenarioId : Nat, voterId : Principal, choice : Scenario.ScenarioChoiceKind) : async* Result.Result<(), GenericProposalEngine.VoteError or { #scenarioNotFound; #invalidChoice }> {
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

    private func toMutableScenario<system>(scenario : Scenario.Scenario) : MutableScenario {
        let kind : MutableScenarioKind = switch (scenario.kind) {
            case (#mysteriousStructure(mysteriousStructure)) #mysteriousStructure(toMutableMysteriousStructureScenario<system>(mysteriousStructure));
        };
        {
            id = scenario.id;
            kind = kind;
        };
    };

    private func fromMutableScenario(scenario : MutableScenario) : Scenario.Scenario {
        {
            id = scenario.id;
            kind = switch (scenario.kind) {
                case (#mysteriousStructure(mysteriousStructure)) #mysteriousStructure(fromMutableMysteriousStructureScenario(scenario.id, mysteriousStructure));
            };
        };
    };

    private func toMutableMysteriousStructureScenario<system>(
        mysteriousStructure : Scenario.ScenarioData<MysteriousStructureScenario.MetaData, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice>
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

    private func fromMutableMysteriousStructureScenario(
        scenarioId : Nat,
        mysteriousStructure : MutableScenarioData<MysteriousStructureScenario.MetaData, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice>,
    ) : Scenario.ScenarioData<MysteriousStructureScenario.MetaData, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice> {
        let ?proposal = mysteriousStructure.proposalEngine.getProposal(0) // TODO better way?
        else Debug.trap("Proposal not found for mysterious structure scenario: " # Nat.toText(scenarioId));
        {
            proposal = proposal;
            metaData = mysteriousStructure.metaData;
        };
    };
};
