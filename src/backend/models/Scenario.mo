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

    public type ScenarioOptionDiscrete = {
        title : Text;
        description : Text;
        energyCost : Nat;
        traitRequirements : [TraitRequirement];
        teamEffect : Effect;
        allowedTeamIds : [Nat];
    };

    public type NoLeagueEffectScenario = {
        options : [ScenarioOptionDiscrete];
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

    public type ThresholdScenarioOption = ScenarioOptionDiscrete and {
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

    public type LeagueChoiceScenarioOption = ScenarioOptionDiscrete and {
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
        scenarioOutcome : ScenarioOutcome;
        effectOutcomes : [EffectOutcome];
        options : ScenarioResolvedOptions;
    };

    public type ScenarioResolvedOptions = {
        #discrete : [ScenarioResolvedOptionDiscrete];
        #nat : [ScenarioResolvedOptionNat];
    };

    public type ScenarioResolvedOptionDiscrete = {
        optionId : Nat;
        teams : [ScenarioResolvedOptionDiscreteTeam];
    };

    public type ScenarioResolvedOptionDiscreteTeam = {
        teamId : Nat;
        isChosen : Bool;
    };

    public type ScenarioResolvedOptionNat = {
        value : Nat;
        teamIds : [Nat];
    };

    public type ScenarioOutcome = {
        #threshold : ThresholdScenarioOutcome;
        #leagueChoice : LeagueChoiceScenarioOutcome;
        #lottery : LotteryScenarioOutcome;
        #proportionalBid : ProportionalBidScenarioOutcome;
        #noLeagueEffect;
    };

    public type ThresholdScenarioOutcome = {
        contributions : [ThresholdContribution];
        successful : Bool;
    };

    public type ThresholdContribution = {
        teamId : Nat;
        amount : Int;
    };

    public type LeagueChoiceScenarioOutcome = {
        optionId : ?Nat;
    };

    public type LotteryScenarioOutcome = {
        winningTeamId : ?Nat;
    };

    public type ProportionalBidScenarioOutcome = {
        bids : [ProportionalWinningBid];
    };

    public type ProportionalWinningBid = {
        teamId : Nat;
        proportion : Nat;
    };

};
