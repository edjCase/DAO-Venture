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
import MysteriousStructure "../scenarios/MysteriousStructure";
import OutcomeHandler "OutcomeHandler";
import CharacterHandler "CharacterHandler";
import DarkElfAmbush "../scenarios/DarkElfAmbush";
import CorruptedTreant "../scenarios/CorruptedTreant";
import GoblinRaidingParty "../scenarios/GoblinRaidingParty";
import LostElfling "../scenarios/LostElfling";
import TrappedDruid "../scenarios/TrappedDruid";
import SinkingBoat "../scenarios/SinkingBoat";
import WanderingAlchemist "../scenarios/WanderingAlchemist";
import DwarvenWeaponsmith "../scenarios/DwarvenWeaponsmith";
import FairyMarket "../scenarios/FairyMarket";
import ScenarioHelper "../ScenarioHelper";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        scenarios : [Scenario];
    };

    public type Scenario = Scenario.Scenario and {
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
        data : StableData,
        characterHandler : CharacterHandler.Handler,
    ) {
        let votingThreshold = #percent({ percent = 50; quorum = ?20 });
        let scenarios = data.scenarios.vals()
        |> Iter.map<Scenario, (Nat, Scenario)>(
            _,
            func(scenario : Scenario) : (Nat, Scenario) = (scenario.id, scenario),
        )
        |> HashMap.fromIter<Nat, Scenario>(_, data.scenarios.size(), Nat.equal, Nat32.fromNat);

        public func toStableData() : StableData {
            {
                scenarios = scenarios.vals()
                |> Iter.toArray(_);
            };
        };

        public func start(
            kind : Scenario.ScenarioKind,
            proposerId : Principal,
            members : [ExtendedProposal.Member],
        ) : Nat {
            let scenarioId = scenarios.size(); // TODO?

            let newScenario : Scenario = create(
                scenarioId,
                kind,
                proposerId,
                members,
            );

            scenarios.put(scenarioId, newScenario);
            scenarioId;
        };

        public func generateAndStart(prng : Prng, proposerId : Principal, members : [ExtendedProposal.Member]) : Nat {
            let kind = generateRandomKind(prng);
            start(kind, proposerId, members);
        };

        public func get(scenarioId : Nat) : ?Scenario.Scenario {
            scenarios.get(scenarioId);
        };

        public func getAll() : [Scenario.Scenario] {
            scenarios.vals()
            |> Iter.sort(
                _,
                func(a : Scenario.Scenario, b : Scenario.Scenario) : Order.Order = Nat.compare(a.id, b.id),
            )
            |> Iter.toArray(_);
        };

        public func getVote(
            scenarioId : Nat,
            voterId : Principal,
        ) : GetVoteResult {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);

            let vote = ExtendedProposal.getVote(scenario.proposal, voterId);
            let ?v = vote else return #err(#notEligible);
            #ok(v);
        };

        public func getVoteSummary(scenarioId : Nat) : GetVoteSummaryResult {
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
        ) : Result.Result<(), VoteError> {
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

        public func end(prng : Prng, scenarioId : Nat) : Result.Result<(), { #scenarioNotFound; #alreadyEnded; #invalidChoice }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            if (scenario.outcome != null) {
                return #err(#alreadyEnded);
            };
            Debug.print("Ending scenario " # Nat.toText(scenarioId));
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
            let outcomeHandler = OutcomeHandler.Handler(prng, characterHandler);

            let helper = ScenarioHelper.fromKind(scenario.kind);
            helper.processOutcome(
                prng,
                outcomeHandler,
                choiceOrUndecided,
            );
            let outcome = {
                choice = choiceOrUndecided;
                messages = outcomeHandler.getMessages();
            };

            scenarios.put(
                scenarioId,
                {
                    scenario with
                    outcome = ?outcome;
                },
            );
            #ok;
        };

    };

    public func generateRandomKind(prng : Prng) : Scenario.ScenarioKind {
        prng.optionBuilder<Scenario.ScenarioKind>()
        // prettier-ignore
        .withFunc(func() : Scenario.ScenarioKind = #mysteriousStructure(MysteriousStructure.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #darkElfAmbush(DarkElfAmbush.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #corruptedTreant(CorruptedTreant.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #goblinRaidingParty(GoblinRaidingParty.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #lostElfling(LostElfling.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #trappedDruid(TrappedDruid.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #sinkingBoat(SinkingBoat.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #wanderingAlchemist(WanderingAlchemist.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #dwarvenWeaponsmith(DwarvenWeaponsmith.generate(prng)), 1.0)
        .withFunc(func() : Scenario.ScenarioKind = #fairyMarket(FairyMarket.generate(prng)), 1.0)
        .next();
    };

    public func create(id : Nat, kind : Scenario.ScenarioKind, proposerId : Principal, members : [ExtendedProposal.Member]) : Scenario {
        {
            id = id;
            kind = kind;
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
