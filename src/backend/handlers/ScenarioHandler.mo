import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Random "mo:base/Random";
import Error "mo:base/Error";
import Option "mo:base/Option";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import MysteriousStructureScenario "../scenarios/MysteriousStructure";
import Scenario "../models/Scenario";
import CommonTypes "../CommonTypes";
import IterTools "mo:itertools/Iter";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import MysteriousStructure "../scenarios/MysteriousStructure";
import OutcomeHandler "OutcomeHandler";
import CharacterHandler "CharacterHandler";

module {
    public type StableData = {
        scenarios : [Scenario.Scenario];
    };

    public class Handler<system>(
        data : StableData,
        characterHandler : CharacterHandler.Handler,
    ) {
        let votingThreshold = #percent({ percent = 50; quorum = ?20 });
        let scenarios = data.scenarios.vals()
        |> Iter.map<Scenario.Scenario, (Nat, Scenario.Scenario)>(
            _,
            func(scenario : Scenario.Scenario) : (Nat, Scenario.Scenario) = (scenario.id, scenario),
        )
        |> HashMap.fromIter<Nat, Scenario.Scenario>(_, data.scenarios.size(), Nat.equal, Nat32.fromNat);

        public func toStableData() : StableData {
            {
                scenarios = scenarios.vals()
                |> Iter.toArray(_);
            };
        };

        public func start<system>(turn : Nat, kind : Scenario.ScenarioKind) : Nat {
            let scenarioId = scenarios.size(); // TODO?
            scenarios.put(
                scenarioId,
                {
                    id = scenarioId;
                    turn = turn;
                    kind = kind;
                },
            );
            scenarioId;
        };

        public func get(scenarioId : Nat) : ?Scenario.Scenario {
            scenarios.get(scenarioId);
        };

        public func getAll(count : Nat, offset : Nat) : CommonTypes.PagedResult<Scenario.Scenario> {
            var filteredScenarios = scenarios.vals()
            |> Iter.sort(
                _,
                func(a : Scenario.Scenario, b : Scenario.Scenario) : Order.Order = Nat.compare(a.id, b.id),
            )
            |> IterTools.skip(_, offset)
            |> IterTools.take(_, count)
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
        ) : Result.Result<ExtendedProposal.Vote<Scenario.ScenarioChoiceKind>, { #scenarioNotFound; #notEligible }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let result : ?ExtendedProposal.Vote<Scenario.ScenarioChoiceKind> = switch (scenario.kind) {
                case (#mysteriousStructure(mysteriousStructure)) {
                    let vote = ExtendedProposal.getVote(mysteriousStructure.proposal, voterId);
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

        public func getVoteSummary(scenarioId : Nat) : Result.Result<ExtendedProposal.VotingSummary<Scenario.ScenarioChoiceKind>, { #scenarioNotFound }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let summary : ExtendedProposal.VotingSummary<Scenario.ScenarioChoiceKind> = switch (scenario.kind) {
                case (#mysteriousStructure(mysteriousStructure)) {
                    let summary = ExtendedProposal.buildVotingSummary(
                        mysteriousStructure.proposal,
                        MysteriousStructureScenario.equalChoice,
                        MysteriousStructureScenario.hashChoice,
                    );
                    {
                        summary with
                        votingPowerByChoice = summary.votingPowerByChoice.vals()
                        |> Iter.map(
                            _,
                            func(
                                choice : ExtendedProposal.ChoiceVotingPower<MysteriousStructureScenario.Choice>
                            ) : ExtendedProposal.ChoiceVotingPower<Scenario.ScenarioChoiceKind> = {
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

        public func vote(
            scenarioId : Nat,
            voterId : Principal,
            choice : Scenario.ScenarioChoiceKind,
        ) : async* Result.Result<(), ExtendedProposal.VoteError or { #scenarioNotFound; #invalidChoice }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            switch (scenario.kind) {
                case (#mysteriousStructure(mysteriousStructure)) {
                    let #mysteriousStructure(mysteriousStructureChoice) = choice else return #err(#invalidChoice);
                    let voteResult = ExtendedProposal.vote(
                        mysteriousStructure.proposal,
                        voterId,
                        mysteriousStructureChoice,
                        votingThreshold,
                        MysteriousStructure.equalChoice,
                        MysteriousStructure.hashChoice,
                    );
                    switch (voteResult) {
                        case (#ok(ok)) {
                            switch (ok.choiceStatus) {
                                case (#determined(choiceOrUndecided)) {
                                    let randomBlob = label l : Blob loop {
                                        try {
                                            let blob = await Random.blob();
                                            break l(blob);
                                        } catch (err) {
                                            Debug.print("Failed to generate random blob, retrying... Error: " # Error.message(err));
                                            continue l;
                                        };
                                    };
                                    let prng = PseudoRandomX.fromBlob(randomBlob, #xorshift32);
                                    let outcomeHandler = OutcomeHandler.Handler(prng, characterHandler);
                                    let choice = Option.get(choiceOrUndecided, #skip); // TODO random?
                                    MysteriousStructure.processOutcome(prng, outcomeHandler, choice);
                                };
                                case (#undetermined) ();
                            };
                            scenarios.put(
                                scenarioId,
                                {
                                    scenario with
                                    kind = #mysteriousStructure({
                                        mysteriousStructure with
                                        proposal = ok.updatedProposal;
                                    });
                                },
                            );
                            #ok;
                        };
                        case (#err(err)) return #err(err);
                    };
                };
            };
        };

    };
};
