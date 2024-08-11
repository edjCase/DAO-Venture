import Nat "mo:base/Nat";
import GenericProposalEngine "mo:dao-proposal-engine/GenericProposalEngine";
import MysteriousStructureScenario "../scenarios/MysteriousStructure";

module {

    public type Scenario = {
        id : Nat;
        turn : Nat;
        kind : ScenarioKind;
    };

    public type ScenarioKind = {
        #mysteriousStructure : ScenarioData<MysteriousStructureScenario.LocationData, MysteriousStructureScenario.ProposalContent, MysteriousStructureScenario.Choice>;
    };

    public type ScenarioData<LocationData, ProposalContent, Choice> = {
        proposal : GenericProposalEngine.Proposal<ProposalContent, Choice>;
        metaData : LocationData;
    };

    public type ScenarioChoiceKind = {
        #mysteriousStructure : MysteriousStructureScenario.Choice;
    };
};
