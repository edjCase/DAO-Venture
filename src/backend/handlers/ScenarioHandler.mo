import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Nat32 "mo:base/Nat32";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import Scenario "../models/Scenario";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "../models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        instances : [ScenarioInstance];
    };

    public type ScenarioInstance = Scenario.Scenario and {
        proposal : ExtendedProposal.Proposal<{}, Text>;
    };

    public type VoteError = ExtendedProposal.VoteError or {
        #scenarioNotFound;
        #invalidChoice;
    };

    public type GetVoteResult = Result.Result<ExtendedProposal.Vote<Text>, { #scenarioNotFound; #notEligible }>;

    public type GetVoteSummaryResult = Result.Result<ExtendedProposal.VotingSummary<Text>, { #scenarioNotFound }>;

    public type Member = ExtendedProposal.Member;

    public class Handler<system>(
        data : StableData
    ) {
        let votingThreshold = #percent({ percent = 50; quorum = ?20 });
        let instances = data.instances.vals()
        |> Iter.map<ScenarioInstance, (Nat, ScenarioInstance)>(
            _,
            func(scenario : ScenarioInstance) : (Nat, ScenarioInstance) = (scenario.id, scenario),
        )
        |> HashMap.fromIter<Nat, ScenarioInstance>(_, data.instances.size(), Nat.equal, Nat32.fromNat);

        public func toStableData() : StableData {
            {
                instances = instances.vals()
                |> Iter.toArray(_);
            };
        };

        public func start(
            scenario : {
                metaDataId : Text;
                data : [Scenario.GeneratedDataFieldInstance];
            },
            proposerId : Principal,
            members : [ExtendedProposal.Member],
        ) : Nat {
            let scenarioId = instances.size(); // TODO?

            let newInstance : ScenarioInstance = create(
                scenarioId,
                scenario,
                proposerId,
                members,
            );

            instances.put(scenarioId, newInstance);
            scenarioId;
        };

        public func get(scenarioId : Nat) : ?ScenarioInstance {
            instances.get(scenarioId);
        };

        public func getAll() : [ScenarioInstance] {
            instances.vals()
            |> Iter.sort(
                _,
                func(a : ScenarioInstance, b : ScenarioInstance) : Order.Order = Nat.compare(a.id, b.id),
            )
            |> Iter.toArray(_);
        };

        public func getVote(
            scenarioId : Nat,
            voterId : Principal,
        ) : GetVoteResult {
            let ?scenario = instances.get(scenarioId) else return #err(#scenarioNotFound);

            let vote = ExtendedProposal.getVote(scenario.proposal, voterId);
            let ?v = vote else return #err(#notEligible);
            #ok(v);
        };

        public func getVoteSummary(scenarioId : Nat) : GetVoteSummaryResult {
            let ?scenario = instances.get(scenarioId) else return #err(#scenarioNotFound);
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
            choiceId : Text,
        ) : Result.Result<?Text, VoteError> {
            let ?scenario = instances.get(scenarioId) else return #err(#scenarioNotFound);
            let voteResult = ExtendedProposal.vote(
                scenario.proposal,
                voterId,
                choiceId,
            );
            switch (voteResult) {
                case (#ok(ok)) {
                    instances.put(
                        scenarioId,
                        {
                            scenario with
                            proposal = ok.updatedProposal;
                        },
                    );
                    // Calculate if choice is determined/scenario is over
                    switch (
                        ExtendedProposal.calculateVoteStatus(
                            ok.updatedProposal,
                            votingThreshold,
                            Text.equal,
                            Text.hash,
                            false,
                        )
                    ) {
                        case (#determined(choiceOrNull)) #ok(choiceOrNull);
                        case (#undetermined) #ok(null);
                    };
                };
                case (#err(err)) return #err(err);
            };
        };

        public func end(
            scenarioId : Nat,
            outcome : Outcome.Outcome,
        ) : Result.Result<(), { #scenarioNotFound; #alreadyEnded; #invalidChoice }> {
            let ?scenario = instances.get(scenarioId) else return #err(#scenarioNotFound);
            if (scenario.outcome != null) {
                return #err(#alreadyEnded);
            };
            Debug.print("Ending scenario " # Nat.toText(scenarioId));

            instances.put(
                scenarioId,
                {
                    scenario with
                    outcome = ?outcome;
                },
            );
            #ok;
        };
    };

    public func create(
        id : Nat,
        scenario : {
            metaDataId : Text;
            data : [Scenario.GeneratedDataFieldInstance];
        },
        proposerId : Principal,
        members : [ExtendedProposal.Member],
    ) : ScenarioInstance {
        {
            scenario with
            id = id;
            proposal = {
                id = id;
                proposerId = proposerId;
                timeStart = Time.now();
                timeEnd = null;
                content = {};
                votes = members.vals()
                |> Iter.map<ExtendedProposal.Member, (Principal, ExtendedProposal.Vote<Text>)>(
                    _,
                    func(member : ExtendedProposal.Member) : (Principal, ExtendedProposal.Vote<Text>) = (
                        member.id,
                        {
                            choice = null;
                            votingPower = member.votingPower;
                        },
                    ),
                )
                |> Iter.toArray(_);
                status = #open;
            };
            outcome = null;
        };
    };

};
