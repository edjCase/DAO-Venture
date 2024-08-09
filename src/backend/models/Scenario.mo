import Nat "mo:base/Nat";
import GenericProposalEngine "mo:dao-proposal-engine/GenericProposalEngine";
import MysteriousStructureScenario "../scenarios/MysteriousStructure";

module {

    public type Scenario = {
        id : Nat;
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
};
