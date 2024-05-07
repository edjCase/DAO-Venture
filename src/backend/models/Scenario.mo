import Skill "Skill";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Player "Player";
import FieldPosition "FieldPosition";

module {

    public type TargetTeam = {
        #choosingTeam;
    };

    public type TargetPosition = {
        team : TargetTeam;
        position : FieldPosition.FieldPosition;
    };

    public type LeagueOrTeamsTarget = {
        #league;
        #teams : [TargetTeam];
    };

    public type Target = {
        #league;
        #teams : [TargetTeam];
        #positions : [TargetPosition];
    };

    public type Duration = {
        #indefinite;
        #matches : Nat;
    };

    public type WeightedEffect = {
        weight : Nat;
        effect : Effect;
        description : Text;
    };

    public type Effect = {
        #skill : {
            target : Target;
            skill : Skill.Skill;
            duration : Duration;
            delta : Int;
        };
        #injury : {
            target : Target;
            injury : Player.Injury;
        };
        #entropy : {
            target : LeagueOrTeamsTarget;
            delta : Int;
        };
        #energy : {
            team : TargetTeam;
            value : {
                #flat : Int;
            };
        };
        #oneOf : [WeightedEffect];
        #allOf : [Effect];
        #noEffect;
    };

    public type PlayerEffectOutcome = {
        #skill : {
            target : TargetInstance;
            skill : Skill.Skill;
            duration : Duration;
            delta : Int;
        };
        #injury : {
            target : TargetInstance;
            injury : Player.Injury;
        };
    };

    public type TeamEffectOutcome = {
        #entropy : {
            teamId : Nat;
            delta : Int;
        };
        #energy : {
            teamId : Nat;
            delta : Int;
        };
    };

    public type EffectOutcome = PlayerEffectOutcome or TeamEffectOutcome;

    public type TargetInstance = {
        #league;
        #teams : [Nat];
        #positions : [TargetPositionInstance];
    };

    public type TargetPositionInstance = {
        teamId : Nat;
        position : FieldPosition.FieldPosition;
    };

    public type ScenarioOption = {
        title : Text;
        description : Text;
        energyCost : Nat;
    };

    public type ScenarioOptionWithEffect = ScenarioOption and {
        effect : Effect;
    };

    public type Scenario = {
        id : Nat;
        title : Text;
        description : Text;
        startTime : Int;
        endTime : Int;
        abstainEffect : Effect;
        options : [ScenarioOptionWithEffect];
        metaEffect : MetaEffect;
        state : ScenarioState;
    };

    public type ScenarioState = {
        #notStarted;
        #inProgress;
        #resolved : ScenarioStateResolved;
    };

    public type ThresholdContribution = {
        teamId : Nat;
        amount : Int;
    };

    public type ScenarioStateResolved = {
        teamChoices : [{
            teamId : Nat;
            option : ?Nat;
        }];
        metaEffectOutcome : MetaEffectOutcome;
        effectOutcomes : [EffectOutcome];
    };

    public type MetaEffectOutcome = {
        #threshold : {
            contributions : [ThresholdContribution];
            successful : Bool;
        };
        #leagueChoice : {
            optionId : ?Nat;
        };
        #lottery : {
            winningTeamId : ?Nat;
        };
        #proportionalBid : {
            winningBids : [{
                teamId : Nat;
                amount : Nat;
            }];
        };
        #noEffect;
    };

    public type ThresholdOptionValue = {
        #fixed : Int;
        #weightedChance : [{
            value : Int;
            weight : Nat;
            description : Text;
        }];
    };

    public type MetaEffect = {
        #noEffect;
        #threshold : {
            minAmount : Nat;
            success : {
                description : Text;
                effect : Effect;
            };
            failure : {
                description : Text;
                effect : Effect;
            };
            abstainAmount : ThresholdOptionValue;
            options : [{
                value : ThresholdOptionValue;
            }];
        };
        #leagueChoice : {
            options : [{
                effect : Effect;
            }];
        };
        // #pickASide : {
        //     options : [{
        //         sideId : Text;
        //     }];
        // };
        // #winnerTakeAllBid : {
        //     prize : Effect;
        //     options : [{
        //         // TODO
        //     }];
        // };
        #lottery : {
            prize : Effect;
            options : [{
                tickets : Nat;
            }];
        };
        #proportionalBid : {
            prize : {
                amount : Nat;
                kind : {
                    #skill : {
                        skill : Skill.Skill;
                        target : {
                            #position : FieldPosition.FieldPosition;
                        };
                        duration : Duration;
                    };
                };
            };
            options : [{
                bidValue : Nat;
            }];
        };
    };

};
