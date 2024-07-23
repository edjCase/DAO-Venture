import Nat "mo:base/Nat";
import Text "mo:base/Text";
import World "World";

module {
    public type TargetTown = {
        #contextual;
        #random : Nat; // Number of random towns
        #chosen : [Nat];
        #all;
    };

    public type ReverseEffect = {
        // TODO anomoly
        // #anomoly : {
        //     townId : Nat;
        //     anomoly : Anomoly.Anomoly;
        // };
    };

    public type Effect = {
        // TODO anomoly
        // #anomoly : AnomolyEffect;
        #entropy : EntropyEffect;
        #resource : ResourceEffect;
        #oneOf : [WeightedEffect];
        #allOf : [Effect];
        #noEffect;
    };

    // TODO anomoly
    // public type AnomolyEffect = {
    //     town : TargetTown;
    //     duration : Duration;
    //     anomoly : Anomoly.Anomoly;
    // };

    public type EntropyThresholdEffect = {
        delta : Int;
    };

    public type WorldIncomeEffect = {
        delta : Int;
    };

    public type EntropyEffect = {
        town : TargetTown;
        delta : Int;
    };

    public type ResourceEffect = {
        town : TargetTown;
        kind : World.ResourceKind;
        value : {
            #flat : Int;
        };
    };

    public type WeightedEffect = {
        weight : Nat;
        effect : Effect;
        description : Text;
    };

    public type TownEffectOutcome = {
        #entropy : EntropyTownEffectOutcome;
        #resource : ResourceTownEffectOutcome;
    };

    public type EntropyTownEffectOutcome = {
        townId : Nat;
        delta : Int;
    };

    public type ResourceTownEffectOutcome = {
        townId : Nat;
        kind : World.ResourceKind;
        delta : Int;
    };

    // TODO anomoly
    // public type AnomolyMatchEffectOutcome = {
    //     townId : Nat;
    //     anomoly : Anomoly.Anomoly;
    //     duration : Duration;
    // };

    public type EffectOutcome = TownEffectOutcome;

    public type Requirement = {
        #size : RangeRequirement;
        #entropy : RangeRequirement;
        #age : RangeRequirement;
        #population : RangeRequirement;
        #resource : ResourceRequirement;
    };

    public type ResourceRequirement = {
        kind : World.ResourceKind;
        range : RangeRequirement;
    };

    public type RangeRequirement = {
        #above : Nat;
        #below : Nat;
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
        #noWorldEffect : NoWorldEffectScenario;
        #threshold : ThresholdScenario;
        #worldChoice : WorldChoiceScenario;
        #lottery : LotteryScenario;
        #proportionalBid : ProportionalBidScenario;
        #textInput : TextInputScenario;
    };

    public type ScenarioOptionDiscrete = {
        title : Text;
        description : Text;
        resourceCosts : [ResourceCost];
        requirements : [Requirement];
        townEffect : Effect;
        allowedTownIds : [Nat];
    };

    public type ResourceCost = {
        kind : World.ResourceKind;
        amount : Nat;
    };

    public type NoWorldEffectScenario = {
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

    public type WorldChoiceScenario = {
        options : [WorldChoiceScenarioOption];
    };

    public type WorldChoiceScenarioOption = ScenarioOptionDiscrete and {
        worldEffect : Effect;
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
        optionsForTown : [Nat];
    };

    public type ScenarioStateResolved = {
        scenarioOutcome : ScenarioOutcome;
        effectOutcomes : [EffectOutcome];
        options : ScenarioResolvedOptions;
    };

    public type ScenarioResolvedOptions = {
        undecidedOption : {
            townEffect : Effect;
            chosenByTownIds : [Nat];
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
        resourceCosts : [ResourceCost];
        requirements : [Requirement];
        townEffect : Effect;
        seenByTownIds : [Nat];
        chosenByTownIds : [Nat];
    };

    public type ScenarioResolvedOptionRaw<T> = {
        value : T;
        chosenByTownIds : [Nat];
    };

    public type ScenarioOutcome = {
        #threshold : ThresholdScenarioOutcome;
        #worldChoice : WorldChoiceScenarioOutcome;
        #lottery : LotteryScenarioOutcome;
        #proportionalBid : ProportionalBidScenarioOutcome;
        #textInput : TextInputScenarioOutcome;
        #noWorldEffect;
    };

    public type ThresholdScenarioOutcome = {
        contributions : [ThresholdContribution];
        successful : Bool;
    };

    public type ThresholdContribution = {
        townId : Nat;
        amount : Int;
    };

    public type WorldChoiceScenarioOutcome = {
        optionId : ?Nat;
    };

    public type LotteryScenarioOutcome = {
        winningTownId : ?Nat;
    };

    public type ProportionalBidScenarioOutcome = {
        bids : [ProportionalWinningBid];
    };

    public type TextInputScenarioOutcome = {
        text : Text;
    };

    public type ProportionalWinningBid = {
        townId : Nat;
        proportion : Nat;
    };

    public type ScenarioOptionValue = {
        #nat : Nat;
        #id : Nat;
        #text : Text;
    };
};
