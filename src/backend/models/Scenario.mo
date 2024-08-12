import Nat "mo:base/Nat";
import ExtendedProposalEngine "mo:dao-proposal-engine/ExtendedProposalEngine";
import MysteriousStructure "../scenarios/MysteriousStructure";
import Outcome "Outcome";

module {

    public type Scenario = {
        id : Nat;
        turn : Nat;
        kind : ScenarioKind;
    };

    public type ProposalContent = {
        locationId : Nat;
    };

    public type ScenarioKind = {
        #mysteriousStructure : ScenarioData<MysteriousStructure.Choice>;
    };

    public type ScenarioData<TChoice> = {
        proposal : ExtendedProposalEngine.Proposal<ProposalContent, TChoice>;
        outcome : ?Outcome.Outcome<TChoice>;
    };

    public type ScenarioChoiceKind = {
        #mysteriousStructure : MysteriousStructure.Choice;
    };

};
