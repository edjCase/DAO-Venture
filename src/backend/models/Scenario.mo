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

    public type ReverseEffect = {
        #skill : {
            playerId : Nat32;
            skill : Skill.Skill;
            deltaToRemove : Int;
        };
        // TODO anomoly
        // #anomoly : {
        //     teamId : Nat;
        //     anomoly : Anomoly.Anomoly;
        // };
    };

    public type Effect = {
        // TODO anomoly
        // #anomoly : AnomolyEffect;
        #entropyThreshold : EntropyThresholdEffect;
        #leagueIncome : LeagueIncomeEffect;
        #teamTrait : TeamTraitEffect;
        #skill : SkillEffect;
        #injury : InjuryEffect;
        #entropy : EntropyEffect;
        #currency : CurrencyEffect;
        #oneOf : [WeightedEffect];
        #allOf : [Effect];
        #noEffect;
    };

    // TODO anomoly
    // public type AnomolyEffect = {
    //     team : TargetTeam;
    //     duration : Duration;
    //     anomoly : Anomoly.Anomoly;
    // };

    public type EntropyThresholdEffect = {
        delta : Int;
    };

    public type LeagueIncomeEffect = {
        delta : Int;
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

    public type CurrencyEffect = {
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
        #currency : CurrencyTeamEffectOutcome;
        #teamTrait : TeamTraitTeamEffectOutcome;
    };

    public type EntropyTeamEffectOutcome = {
        teamId : Nat;
        delta : Int;
    };

    public type CurrencyTeamEffectOutcome = {
        teamId : Nat;
        delta : Int;
    };

    public type TeamTraitTeamEffectOutcome = {
        teamId : Nat;
        traitId : Text;
        kind : TeamTraitEffectKind;
    };

    public type LeagueEffectOutcome = {
        #leagueIncome : LeagueIncomeEffectOutcome;
        #entropyThreshold : EntropyThresholdEffectOutcome;
    };

    public type LeagueIncomeEffectOutcome = {
        delta : Int;
    };

    public type EntropyThresholdEffectOutcome = {
        delta : Int;
    };

    // TODO anomoly
    // public type AnomolyMatchEffectOutcome = {
    //     teamId : Nat;
    //     anomoly : Anomoly.Anomoly;
    //     duration : Duration;
    // };

    public type EffectOutcome = PlayerEffectOutcome or TeamEffectOutcome or LeagueEffectOutcome;

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
        #textInput : TextInputScenario;
    };

    public type ScenarioOptionDiscrete = {
        title : Text;
        description : Text;
        currencyCost : Nat;
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

    public type TextInputScenario = {
        description : Text;
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
        #nat : [ScenarioResolvedOptionRaw<Nat>];
        #text : [ScenarioResolvedOptionRaw<Text>];
    };

    public type ScenarioResolvedOptionDiscrete = {
        id : Nat;
        title : Text;
        description : Text;
        currencyCost : Nat;
        traitRequirements : [TraitRequirement];
        teamEffect : Effect;
        seenByTeamIds : [Nat];
        chosenByTeamIds : [Nat];
    };

    public type ScenarioResolvedOptionRaw<T> = {
        value : T;
        chosenByTeamIds : [Nat];
    };

    public type ScenarioOutcome = {
        #threshold : ThresholdScenarioOutcome;
        #leagueChoice : LeagueChoiceScenarioOutcome;
        #lottery : LotteryScenarioOutcome;
        #proportionalBid : ProportionalBidScenarioOutcome;
        #textInput : TextInputScenarioOutcome;
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

    public type TextInputScenarioOutcome = {
        text : Text;
    };

    public type ProportionalWinningBid = {
        teamId : Nat;
        proportion : Nat;
    };

    public type ScenarioOptionValue = {
        #nat : Nat;
        #id : Nat;
        #text : Text;
    };
};
