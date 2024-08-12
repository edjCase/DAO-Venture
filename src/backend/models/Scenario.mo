import Nat "mo:base/Nat";
import ExtendedProposalEngine "mo:dao-proposal-engine/ExtendedProposalEngine";
import MysteriousStructureScenario "../scenarios/MysteriousStructure";

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
        #mysteriousStructure : ScenarioData<MysteriousStructureScenario.Choice>;
    };

    public type ScenarioData<Choice> = {
        proposal : ExtendedProposalEngine.Proposal<ProposalContent, Choice>;
    };

    public type ScenarioChoiceKind = {
        #mysteriousStructure : MysteriousStructureScenario.Choice;
    };
};
