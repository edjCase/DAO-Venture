import Nat "mo:base/Nat";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Outcome "Outcome";
import MysteriousStructure "../scenarios/MysteriousStructure";
import DarkElfAmbush "../scenarios/DarkElfAmbush";
import CorruptedTreant "../scenarios/CorruptedTreant";
import GoblinRaidingParty "../scenarios/GoblinRaidingParty";
import LostElfling "../scenarios/LostElfling";
import TrappedDruid "../scenarios/TrappedDruid";
import SinkingBoat "../scenarios/SinkingBoat";
import WanderingAlchemist "../scenarios/WanderingAlchemist";
import DwarvenWeaponsmith "../scenarios/DwarvenWeaponsmith";
import FairyMarket "../scenarios/FairyMarket";
// import AncientElvenRuins "../scenarios/AncientElvenRuins";
// import MysteriousGlade "../scenarios/MysteriousGlade";
// import ForgottenShrine "../scenarios/ForgottenShrine";
// import FeudingFaeries "../scenarios/FeudingFaeries";
// import CursedArtifact "../scenarios/CursedArtifact";
// import WoundedPredator "../scenarios/WoundedPredator";
// import AncientsRequest "../scenarios/AncientsRequest";
// import LostInTime "../scenarios/LostInTime";
// import GreatTreeRoots "../scenarios/GreatTreeRoots";
// import ManaSpring "../scenarios/ManaSpring";
// import BountifulGrove "../scenarios/BountifulGrove";
// import CursedClearing "../scenarios/CursedClearing";
// import WarriorsTrial "../scenarios/WarriorsTrial";
// import MagesPuzzle "../scenarios/MagesPuzzle";
// import RangersLookout "../scenarios/RangersLookout";
// import EnchantedForge "../scenarios/EnchantedForge";
// import SylvanWeaver "../scenarios/SylvanWeaver";
// import RunestoneCircle "../scenarios/RunestoneCircle";
// import PoisonousSporeCloud "../scenarios/PoisonousSporeCloud";
// import MagicalQuicksand "../scenarios/MagicalQuicksand";
// import StormOfWhispers "../scenarios/StormOfWhispers";
// import MysticPortal "../scenarios/MysticPortal";
// import ShiftingPaths "../scenarios/ShiftingPaths";
// import SeasonalShift "../scenarios/SeasonalShift";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Scenario = {
        id : Nat;
        kind : ScenarioKind;
        outcome : ?Outcome.Outcome;
    };

    public type ScenarioKind = {
        #mysteriousStructure : MysteriousStructure.Data;
        #darkElfAmbush : DarkElfAmbush.Data;
        #corruptedTreant : CorruptedTreant.Data;
        #goblinRaidingParty : GoblinRaidingParty.Data;
        #lostElfling : LostElfling.Data;
        #trappedDruid : TrappedDruid.Data;
        #sinkingBoat : SinkingBoat.Data;
        #wanderingAlchemist : WanderingAlchemist.Data;
        #dwarvenWeaponsmith : DwarvenWeaponsmith.Data;
        #fairyMarket : FairyMarket.Data;
        // #ancientElvenRuins : AncientElvenRuins.Data;
        // #mysteriousGlade : MysteriousGlade.Data;
        // #forgottenShrine : ForgottenShrine.Data;
        // #feudingFaeries : FeudingFaeries.Data;
        // #cursedArtifact : CursedArtifact.Data;
        // #woundedPredator : WoundedPredator.Data;
        // #ancientsRequest : AncientsRequest.Data;
        // #lostInTime : LostInTime.Data;
        // #greatTreeRoots : GreatTreeRoots.Data;
        // #manaSpring : ManaSpring.Data;
        // #bountifulGrove : BountifulGrove.Data;
        // #cursedClearing : CursedClearing.Data;
        // #warriorsTrial : WarriorsTrial.Data;
        // #magesPuzzle : MagesPuzzle.Data;
        // #rangersLookout : RangersLookout.Data;
        // #enchantedForge : EnchantedForge.Data;
        // #sylvanWeaver : SylvanWeaver.Data;
        // #runestoneCircle : RunestoneCircle.Data;
        // #poisonousSporeCloud : PoisonousSporeCloud.Data;
        // #magicalQuicksand : MagicalQuicksand.Data;
        // #stormOfWhispers : StormOfWhispers.Data;
        // #mysticPortal : MysticPortal.Data;
        // #shiftingPaths : ShiftingPaths.Data;
        // #seasonalShift : SeasonalShift.Data;
    };

    public type Class = {
        getChoiceRequirement : (text : Text) -> ?Outcome.ChoiceRequirement;
        getChoiceDescription : (choiceId : Text) -> Text;
        getTitle : () -> Text;
        getDescription : () -> Text;
        getOptions : () -> [{ id : Text; description : Text }];
        processOutcome : (
            prng : Prng,
            outcomeProcessor : Outcome.Processor,
            choiceId : Text,
        ) -> ();
    };

};
