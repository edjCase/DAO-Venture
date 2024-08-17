import Outcome "models/Outcome";
import Scenario "models/Scenario";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Debug "mo:base/Debug";
import MysteriousStructure "scenarios/MysteriousStructure";
import CorruptedTreant "scenarios/CorruptedTreant";
import GoblinRaidingParty "scenarios/GoblinRaidingParty";
import LostElfling "scenarios/LostElfling";
import TrappedDruid "scenarios/TrappedDruid";
import SinkingBoat "scenarios/SinkingBoat";
import WanderingAlchemist "scenarios/WanderingAlchemist";
import DwarvenWeaponsmith "scenarios/DwarvenWeaponsmith";
import FairyMarket "scenarios/FairyMarket";
import DarkElfAmbush "scenarios/DarkElfAmbush";
import EnchantedGrove "scenarios/EnchantedGrove";
import KnowledgeNexus "scenarios/KnowledgeNexus";
import MysticForge "scenarios/MysticForge";
import TravelingBard "scenarios/TravelingBard";
import DruidicSanctuary "scenarios/DruidicSanctuary";

module {

    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type ScenarioHelper = {
        isValidChoice : (Text) -> Bool;
        getChoiceRequirement : (Text) -> ?Outcome.ChoiceRequirement;
        getChoiceDescription : (Text) -> Text;
        getTitle : () -> Text;
        getDescription : () -> Text;
        getOptions : () -> [{ id : Text; description : Text }];
        processOutcome : (Prng, Outcome.Processor, ?Text) -> ();
    };

    public func fromKind(kind : Scenario.ScenarioKind) : ScenarioHelper {
        switch (kind) {
            case (#mysteriousStructure(data)) DefaultScenarioHelper<MysteriousStructure.Data, MysteriousStructure.Choice>(
                data,
                MysteriousStructure.choiceFromText,
                MysteriousStructure.getChoiceRequirement,
                MysteriousStructure.getChoiceDescription,
                MysteriousStructure.getTitle,
                MysteriousStructure.getDescription,
                MysteriousStructure.getOptions,
                MysteriousStructure.processOutcome,
            );
            case (#darkElfAmbush(data)) DefaultScenarioHelper<DarkElfAmbush.Data, DarkElfAmbush.Choice>(
                data,
                DarkElfAmbush.choiceFromText,
                DarkElfAmbush.getChoiceRequirement,
                DarkElfAmbush.getChoiceDescription,
                DarkElfAmbush.getTitle,
                DarkElfAmbush.getDescription,
                DarkElfAmbush.getOptions,
                DarkElfAmbush.processOutcome,
            );
            case (#corruptedTreant(data)) DefaultScenarioHelper<CorruptedTreant.Data, CorruptedTreant.Choice>(
                data,
                CorruptedTreant.choiceFromText,
                CorruptedTreant.getChoiceRequirement,
                CorruptedTreant.getChoiceDescription,
                CorruptedTreant.getTitle,
                CorruptedTreant.getDescription,
                CorruptedTreant.getOptions,
                CorruptedTreant.processOutcome,
            );
            case (#goblinRaidingParty(data)) DefaultScenarioHelper<GoblinRaidingParty.Data, GoblinRaidingParty.Choice>(
                data,
                GoblinRaidingParty.choiceFromText,
                GoblinRaidingParty.getChoiceRequirement,
                GoblinRaidingParty.getChoiceDescription,
                GoblinRaidingParty.getTitle,
                GoblinRaidingParty.getDescription,
                GoblinRaidingParty.getOptions,
                GoblinRaidingParty.processOutcome,
            );
            case (#lostElfling(data)) DefaultScenarioHelper<LostElfling.Data, LostElfling.Choice>(
                data,
                LostElfling.choiceFromText,
                LostElfling.getChoiceRequirement,
                LostElfling.getChoiceDescription,
                LostElfling.getTitle,
                LostElfling.getDescription,
                LostElfling.getOptions,
                LostElfling.processOutcome,
            );
            case (#trappedDruid(data)) DefaultScenarioHelper<TrappedDruid.Data, TrappedDruid.Choice>(
                data,
                TrappedDruid.choiceFromText,
                TrappedDruid.getChoiceRequirement,
                TrappedDruid.getChoiceDescription,
                TrappedDruid.getTitle,
                TrappedDruid.getDescription,
                TrappedDruid.getOptions,
                TrappedDruid.processOutcome,
            );
            case (#sinkingBoat(data)) DefaultScenarioHelper<SinkingBoat.Data, SinkingBoat.Choice>(
                data,
                SinkingBoat.choiceFromText,
                SinkingBoat.getChoiceRequirement,
                SinkingBoat.getChoiceDescription,
                SinkingBoat.getTitle,
                SinkingBoat.getDescription,
                SinkingBoat.getOptions,
                SinkingBoat.processOutcome,
            );
            case (#wanderingAlchemist(data)) DefaultScenarioHelper<WanderingAlchemist.Data, WanderingAlchemist.Choice>(
                data,
                WanderingAlchemist.choiceFromText,
                WanderingAlchemist.getChoiceRequirement,
                WanderingAlchemist.getChoiceDescription,
                WanderingAlchemist.getTitle,
                WanderingAlchemist.getDescription,
                WanderingAlchemist.getOptions,
                WanderingAlchemist.processOutcome,
            );
            case (#dwarvenWeaponsmith(data)) DefaultScenarioHelper<DwarvenWeaponsmith.Data, DwarvenWeaponsmith.Choice>(
                data,
                DwarvenWeaponsmith.choiceFromText,
                DwarvenWeaponsmith.getChoiceRequirement,
                DwarvenWeaponsmith.getChoiceDescription,
                DwarvenWeaponsmith.getTitle,
                DwarvenWeaponsmith.getDescription,
                DwarvenWeaponsmith.getOptions,
                DwarvenWeaponsmith.processOutcome,
            );
            case (#fairyMarket(data)) DefaultScenarioHelper<FairyMarket.Data, FairyMarket.Choice>(
                data,
                FairyMarket.choiceFromText,
                FairyMarket.getChoiceRequirement,
                FairyMarket.getChoiceDescription,
                FairyMarket.getTitle,
                FairyMarket.getDescription,
                FairyMarket.getOptions,
                FairyMarket.processOutcome,
            );
            case (#enchantedGrove(data)) DefaultScenarioHelper<EnchantedGrove.Data, EnchantedGrove.Choice>(
                data,
                EnchantedGrove.choiceFromText,
                EnchantedGrove.getChoiceRequirement,
                EnchantedGrove.getChoiceDescription,
                EnchantedGrove.getTitle,
                EnchantedGrove.getDescription,
                EnchantedGrove.getOptions,
                EnchantedGrove.processOutcome,
            );
            case (#knowledgeNexus(data)) DefaultScenarioHelper<KnowledgeNexus.Data, KnowledgeNexus.Choice>(
                data,
                KnowledgeNexus.choiceFromText,
                KnowledgeNexus.getChoiceRequirement,
                KnowledgeNexus.getChoiceDescription,
                KnowledgeNexus.getTitle,
                KnowledgeNexus.getDescription,
                KnowledgeNexus.getOptions,
                KnowledgeNexus.processOutcome,
            );
            case (#mysticForge(data)) DefaultScenarioHelper<MysticForge.Data, MysticForge.Choice>(
                data,
                MysticForge.choiceFromText,
                MysticForge.getChoiceRequirement,
                MysticForge.getChoiceDescription,
                MysticForge.getTitle,
                MysticForge.getDescription,
                MysticForge.getOptions,
                MysticForge.processOutcome,
            );
            case (#travelingBard(data)) DefaultScenarioHelper<TravelingBard.Data, TravelingBard.Choice>(
                data,
                TravelingBard.choiceFromText,
                TravelingBard.getChoiceRequirement,
                TravelingBard.getChoiceDescription,
                TravelingBard.getTitle,
                TravelingBard.getDescription,
                TravelingBard.getOptions,
                TravelingBard.processOutcome,
            );
            case (#druidicSanctuary(data)) DefaultScenarioHelper<DruidicSanctuary.Data, DruidicSanctuary.Choice>(
                data,
                DruidicSanctuary.choiceFromText,
                DruidicSanctuary.getChoiceRequirement,
                DruidicSanctuary.getChoiceDescription,
                DruidicSanctuary.getTitle,
                DruidicSanctuary.getDescription,
                DruidicSanctuary.getOptions,
                DruidicSanctuary.processOutcome,
            );
        };
    };

    public class DefaultScenarioHelper<TData, TChoice>(
        data : TData,
        choiceFromText : (Text) -> ?TChoice,
        getChoiceRequirementInternal : (TChoice) -> ?Outcome.ChoiceRequirement,
        getChoiceDescriptionInternal : (TChoice) -> Text,
        getTitleInternal : () -> Text,
        getDescriptionInternal : () -> Text,
        getOptionsInternal : () -> [{ id : Text; description : Text }],
        processOutcomeInternal : (
            Prng,
            Outcome.Processor,
            TData,
            ?TChoice,
        ) -> (),
    ) : ScenarioHelper {
        public func isValidChoice(choiceId : Text) : Bool {
            switch (choiceFromText(choiceId)) {
                case (?_) true;
                case (null) false;
            };
        };

        public func getChoiceRequirement(choiceId : Text) : ?Outcome.ChoiceRequirement {
            let ?parsedChoice = choiceFromText(choiceId) else Debug.trap("Invalid choice id: " # choiceId);
            getChoiceRequirementInternal(parsedChoice);
        };

        public func getChoiceDescription(choiceId : Text) : Text {
            let ?parsedChoice = choiceFromText(choiceId) else Debug.trap("Invalid choice id: " # choiceId);
            getChoiceDescriptionInternal(parsedChoice);
        };

        public func getTitle() : Text = getTitleInternal();

        public func getDescription() : Text = getDescriptionInternal();

        public func getOptions() : [{ id : Text; description : Text }] = getOptionsInternal();

        public func processOutcome(
            prng : Prng,
            outcomeProcessor : Outcome.Processor,
            choiceIdOrUndecided : ?Text,
        ) {
            let parsedChoice : ?TChoice = switch (choiceIdOrUndecided) {
                case (?choiceId) {
                    let ?parsedChoice = choiceFromText(choiceId) else Debug.trap("Invalid choice id: " # choiceId);
                    ?parsedChoice;
                };
                case (null) null;
            };
            processOutcomeInternal(prng, outcomeProcessor, data, parsedChoice);
        };
    };
};
