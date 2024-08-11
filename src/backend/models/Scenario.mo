import Nat "mo:base/Nat";
import GenericProposalEngine "mo:dao-proposal-engine/GenericProposalEngine";
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
        proposal : GenericProposalEngine.Proposal<ProposalContent, Choice>;
    };

    public type ScenarioChoiceKind = {
        #mysteriousStructure : MysteriousStructureScenario.Choice;
    };
};
