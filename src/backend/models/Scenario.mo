import Skill "Skill";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import FieldPosition "FieldPosition";
import MatchAura "MatchAura";

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
        #matchAura : MatchAuraEffect;
        #teamTrait : TeamTraitEffect;
        #skill : SkillEffect;
        #injury : InjuryEffect;
        #entropy : EntropyEffect;
        #energy : EnergyEffect;
        #oneOf : [WeightedEffect];
        #allOf : [Effect];
        #noEffect;
    };

    public type MatchAuraEffect = {
        team : TargetTeam;
        duration : Duration;
        aura : MatchAura.MatchAura;
    };

    public type SkillEffect = {
        position : TargetPosition;
        skill : ChosenOrRandomSkill;
        duration : Duration;
        delta : Int;
    };

    public type InjuryEffect = {
        position : TargetPosition;
    };

    public type EntropyEffect = {
        team : TargetTeam;
        delta : Int;
    };

    public type EnergyEffect = {
        team : TargetTeam;
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
        team : TargetTeam;
        traitId : Text;
        kind : TeamTraitEffectKind;
    };

    public type PlayerEffectOutcome = {
        #skill : SkillPlayerEffectOutcome;
        #injury : InjuryPlayerEffectOutcome;
    };

    public type SkillPlayerEffectOutcome = {
        position : TargetPositionInstance;
        skill : Skill.Skill;
        duration : Duration;
        delta : Int;
    };

    public type InjuryPlayerEffectOutcome = {
        position : TargetPositionInstance;
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

    public type MatchEffectOutcome = {
        #matchAura : MatchAuraMatchEffectOutcome;
    };

    public type MatchAuraMatchEffectOutcome = {
        teamId : Nat;
        aura : MatchAura.MatchAura;
        duration : Duration;
    };

    public type EffectOutcome = PlayerEffectOutcome or TeamEffectOutcome or MatchEffectOutcome;

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
        prize : LotteryPrize;
        minBid : Nat;
    };

    public type LotteryPrize = {
        description : Text;
        effect : Effect;
    };

    public type ProportionalBidScenario = {
        prize : ProportionalBidPrize;
    };

    public type ProportionalBidPrize = {
        amount : Nat;
        description : Text;
        kind : PropotionalBidPrizeKind;
    };

    public type PropotionalBidPrizeKind = {
        #skill : PropotionalBidPrizeSkill;
    };

    public type PropotionalBidPrizeSkill = {
        skill : ChosenOrRandomSkill;
        position : TargetPosition;
        duration : Duration;
    };

    public type ScenarioState = {
        #notStarted;
        #inProgress;
        #resolving;
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
        undecidedOption : {
            teamEffect : Effect;
            chosenByTeamIds : [Nat];
        };
        kind : ScenarioResolvedOptionsKind;
    };

    public type ScenarioResolvedOptionsKind = {
        #discrete : [ScenarioResolvedOptionDiscrete];
        #nat : [ScenarioResolvedOptionNat];
    };

    public type ScenarioResolvedOptionDiscrete = {
        id : Nat;
        title : Text;
        description : Text;
        energyCost : Nat;
        traitRequirements : [TraitRequirement];
        teamEffect : Effect;
        seenByTeamIds : [Nat];
        chosenByTeamIds : [Nat];
    };

    public type ScenarioResolvedOptionNat = {
        value : Nat;
        chosenByTeamIds : [Nat];
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

    public type ScenarioOptionValue = {
        #nat : Nat;
        #id : Nat;
    };
};
