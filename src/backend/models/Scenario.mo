import Skill "Skill";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import FieldPosition "FieldPosition";

module {
    public type TargetTeam = {
        #contextual;
        #random : Nat; // Number of random teams
        #chosen : [Nat];
        #all;
    };

    public type ChosenOrRandomFieldPosition = {
        #random;
        #chosen : FieldPosition.FieldPosition;
    };

    public type ChosenOrRandomSkill = {
        #random;
        #chosen : Skill.Skill;
    };

    public type TargetPosition = {
        team : TargetTeam;
        position : ChosenOrRandomFieldPosition;
    };

    public type Duration = {
        #indefinite;
        #matches : Nat;
    };

    public type Effect = {
        #teamTrait : TeamTraitEffect;
        #skill : SkillEffect;
        #injury : InjuryEffect;
        #entropy : EntropyEffect;
        #energy : EnergyEffect;
        #oneOf : [WeightedEffect];
        #allOf : [Effect];
        #noEffect;
    };

    public type SkillEffect = {
        target : TargetPosition;
        skill : ChosenOrRandomSkill;
        duration : Duration;
        delta : Int;
    };

    public type InjuryEffect = {
        target : TargetPosition;
    };

    public type EntropyEffect = {
        target : TargetTeam;
        delta : Int;
    };

    public type EnergyEffect = {
        target : TargetTeam;
        value : {
            #flat : Int;
        };
    };

    public type WeightedEffect = {
        weight : Nat;
        effect : Effect;
        description : Text;
    };

    public type TeamTraitEffectKind = {
        #add;
        #remove;
    };

    public type TeamTraitEffect = {
        target : TargetTeam;
        traitId : Text;
        kind : TeamTraitEffectKind;
    };

    public type PlayerEffectOutcome = {
        #skill : SkillPlayerEffectOutcome;
        #injury : InjuryPlayerEffectOutcome;
    };

    public type SkillPlayerEffectOutcome = {
        target : TargetPositionInstance;
        skill : Skill.Skill;
        duration : Duration;
        delta : Int;
    };

    public type InjuryPlayerEffectOutcome = {
        target : TargetPositionInstance;
    };

    public type TeamEffectOutcome = {
        #entropy : EntropyTeamEffectOutcome;
        #energy : EnergyTeamEffectOutcome;
        #teamTrait : TeamTraitTeamEffectOutcome;
    };

    public type EntropyTeamEffectOutcome = {
        teamId : Nat;
        delta : Int;
    };

    public type EnergyTeamEffectOutcome = {
        teamId : Nat;
        delta : Int;
    };

    public type TeamTraitTeamEffectOutcome = {
        teamId : Nat;
        traitId : Text;
        kind : TeamTraitEffectKind;
    };

    public type EffectOutcome = PlayerEffectOutcome or TeamEffectOutcome;

    public type TargetPositionInstance = {
        teamId : Nat;
        position : FieldPosition.FieldPosition;
    };

    public type TraitRequirement = {
        id : Text;
        kind : TraitRequirementKind;
    };

    public type TraitRequirementKind = {
        #required;
        #prohibited;
    };

    public type ScenarioOption = {
        title : Text;
        description : Text;
        energyCost : Nat;
        traitRequirements : [TraitRequirement];
        teamEffect : Effect;
    };

    public type Scenario = {
        id : Nat;
        title : Text;
        description : Text;
        startTime : Int;
        endTime : Int;
        undecidedEffect : Effect;
        kind : ScenarioKind;
        state : ScenarioState;
    };

    public type ScenarioKind = {
        #noLeagueEffect : NoLeagueEffectScenario;
        #threshold : ThresholdScenario;
        #leagueChoice : LeagueChoiceScenario;
        #lottery : LotteryScenario;
        #proportionalBid : ProportionalBidScenario;
    };

    public type NoLeagueEffectScenario = {
        options : [ScenarioOption];
    };

    public type ThresholdScenario = {
        minAmount : Nat;
        success : {
            description : Text;
            effect : Effect;
        };
        failure : {
            description : Text;
            effect : Effect;
        };
        undecidedAmount : ThresholdValue;
        options : [ThresholdScenarioOption];
    };

    public type ThresholdScenarioOption = ScenarioOption and {
        value : ThresholdValue;
    };

    public type ThresholdValue = {
        #fixed : Int;
        #weightedChance : [{
            value : Int;
            weight : Nat;
            description : Text;
        }];
    };

    public type LeagueChoiceScenario = {
        options : [LeagueChoiceScenarioOption];
    };

    public type LeagueChoiceScenarioOption = ScenarioOption and {
        leagueEffect : Effect;
    };

    public type LotteryScenario = {
        prize : Effect;
        minBid : Nat;
    };

    public type ProportionalBidScenario = {
        prize : ProportionalBidPrize;
    };

    public type ProportionalBidPrize = {
        amount : Nat;
        kind : PropotionalBidPrizeKind;
    };

    public type PropotionalBidPrizeKind = {
        #skill : PropotionalBidPrizeSkill;
    };

    public type PropotionalBidPrizeSkill = {
        skill : ChosenOrRandomSkill;
        target : TargetPosition;
        duration : Duration;
    };

    public type ScenarioState = {
        #notStarted;
        #inProgress;
        #resolved : ScenarioStateResolved;
    };

    public type ScenarioStateInProgress = {
        optionsForTeam : [Nat];
    };

    public type ScenarioStateResolved = {
        teamChoices : [ResolvedTeamChoice];
        scenarioOutcome : ScenarioOutcome;
        effectOutcomes : [EffectOutcome];
    };

    public type ResolvedTeamChoice = {
        teamId : Nat;
        optionId : ?Nat;
    };

    public type ScenarioOutcome = {
        #threshold : ThresholdMetaEffectOutcome;
        #leagueChoice : LeagueChoiceMetaEffectOutcome;
        #lottery : LotteryMetaEffectOutcome;
        #proportionalBid : ProportionalBidMetaEffectOutcome;
        #noLeagueEffect;
    };

    public type ThresholdMetaEffectOutcome = {
        contributions : [ThresholdContribution];
        successful : Bool;
    };

    public type ThresholdContribution = {
        teamId : Nat;
        amount : Int;
    };

    public type LeagueChoiceMetaEffectOutcome = {
        optionId : ?Nat;
    };

    public type LotteryMetaEffectOutcome = {
        winningTeamId : ?Nat;
    };

    public type ProportionalBidMetaEffectOutcome = {
        bids : [ProportionalWinningBid];
    };

    public type ProportionalWinningBid = {
        teamId : Nat;
        proportion : Nat;
    };

};
