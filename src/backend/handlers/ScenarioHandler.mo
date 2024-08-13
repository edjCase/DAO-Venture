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
import Text "mo:base/Text";
import Time "mo:base/Time";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import Scenario "../models/Scenario";
import CommonTypes "../CommonTypes";
import IterTools "mo:itertools/Iter";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import MysteriousStructure "../scenarios/MysteriousStructure";
import OutcomeHandler "OutcomeHandler";
import CharacterHandler "CharacterHandler";

module {
    public type StableData = {
        scenarios : [ScenarioData];
    };

    type ScenarioData = Scenario.Scenario and {
        proposal : ExtendedProposal.Proposal<{}, Text>;
    };

    public class Handler<system>(
        data : StableData,
        characterHandler : CharacterHandler.Handler,
    ) {
        let votingThreshold = #percent({ percent = 50; quorum = ?20 });
        let scenarios = data.scenarios.vals()
        |> Iter.map<ScenarioData, (Nat, ScenarioData)>(
            _,
            func(scenario : ScenarioData) : (Nat, ScenarioData) = (scenario.id, scenario),
        )
        |> HashMap.fromIter<Nat, ScenarioData>(_, data.scenarios.size(), Nat.equal, Nat32.fromNat);

        public func toStableData() : StableData {
            {
                scenarios = scenarios.vals()
                |> Iter.toArray(_);
            };
        };

        public func start(turn : Nat, kind : Scenario.ScenarioKind) : Nat {
            let scenarioId = scenarios.size(); // TODO?
            scenarios.put(
                scenarioId,
                {
                    id = scenarioId;
                    turn = turn;
                    kind = kind;
                    proposal = {
                        id = scenarioId;
                        proposerId = Principal.fromText("aa-aaaa"); // TODO
                        timeStart = Time.now();
                        timeEnd = null;
                        content = {};
                        votes = []; // TODO snapshot
                        status = #open;
                    };
                    outcome = null;
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
        ) : Result.Result<ExtendedProposal.Vote<Text>, { #scenarioNotFound; #notEligible }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);

            let vote = ExtendedProposal.getVote(scenario.proposal, voterId);
            let ?v = vote else return #err(#notEligible);
            #ok(v);
        };

        public func getVoteSummary(scenarioId : Nat) : Result.Result<ExtendedProposal.VotingSummary<Text>, { #scenarioNotFound }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let summary = ExtendedProposal.buildVotingSummary(
                scenario.proposal,
                Text.equal,
                Text.hash,
            );

            #ok({
                summary with
                votingPowerByChoice = summary.votingPowerByChoice
            });
        };

        public func vote(
            scenarioId : Nat,
            voterId : Principal,
            choice : Text,
        ) : async* Result.Result<(), ExtendedProposal.VoteError or { #scenarioNotFound; #invalidChoice }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let voteResult = ExtendedProposal.vote(
                scenario.proposal,
                voterId,
                choice,
            );
            // TODO do we want auto execute on vote?
            switch (voteResult) {
                case (#ok(ok)) {
                    scenarios.put(
                        scenarioId,
                        {
                            scenario with
                            proposal = ok.updatedProposal;
                        },
                    );
                    #ok;
                };
                case (#err(err)) return #err(err);
            };
        };

        public func end(scenarioId : Nat) : async* Result.Result<(), { #scenarioNotFound; #alreadyEnded; #invalidChoice }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            if (scenario.outcome != null) {
                return #err(#alreadyEnded);
            };
            let randomBlob = label l : Blob loop {
                try {
                    let blob = await Random.blob();
                    break l(blob);
                } catch (err) {
                    Debug.print("Failed to generate random blob, retrying... Error: " # Error.message(err));
                    continue l;
                };
            };
            let choiceOrUndecided : ?Text = switch (
                ExtendedProposal.calculateVoteStatus(
                    scenario.proposal,
                    votingThreshold,
                    Text.equal,
                    Text.hash,
                    true,
                )
            ) {
                case (#determined(determined)) determined;
                case (#undetermined) null;
            };
            let prng = PseudoRandomX.fromBlob(randomBlob, #xorshift32);
            let outcomeHandler = OutcomeHandler.Handler(prng, characterHandler);
            switch (scenario.kind) {
                case (#mysteriousStructure(_)) {
                    let choice = Option.get(choiceOrUndecided, "skip"); // TODO random?
                    let ?parsedChoice = MysteriousStructure.choiceFromText(choice) else return #err(#invalidChoice);
                    MysteriousStructure.processOutcome(prng, outcomeHandler, parsedChoice);
                };
            };

            scenarios.put(
                scenarioId,
                {
                    scenario with
                    outcome = ?{
                        choice = choiceOrUndecided;
                        messages = outcomeHandler.getMessages();
                    };
                },
            );
            #ok;
        };

    };
};
