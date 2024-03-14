import Skill "Skill";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Player "Player";
import FieldPosition "FieldPosition";

module {

    public type TargetTeam = {
        #choosingTeam;
    };

    public type TargetPlayer = {
        #position : FieldPosition.FieldPosition;
    };

    public type Target = {
        #league;
        #teams : [TargetTeam];
        #players : [TargetPlayer];
    };

    public type Duration = {
        #indefinite;
        #matches : Nat;
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
            team : TargetTeam;
            delta : Int;
        };
        #energy : {
            team : TargetTeam;
            value : {
                #flat : Int;
            };
        };
        #oneOf : [(Nat, Effect)]; // Weighted choices
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
        #players : [Nat32];
    };

    public type ScenarioOption = {
        title : Text;
        description : Text;
        effect : Effect;
    };

    public type Scenario = {
        id : Text;
        title : Text;
        description : Text;
        options : [ScenarioOption];
        metaEffect : MetaEffect;
        state : ScenarioState;
    };

    public type ScenarioState = {
        #notStarted;
        #started;
        #resolved : ScenarioStateResolved;
    };

    public type ScenarioStateResolved = {
        teamChoices : [{
            teamId : Nat;
            option : Nat;
        }];
        effectOutcomes : [EffectOutcome];
    };

    public type MetaEffect = {
        #threshold : {
            threshold : Nat;
            over : Effect;
            under : Effect;
            options : [{
                value : {
                    #fixed : Int;
                    #weightedChance : [(Nat, Int)];
                };
            }];
        };
        #leagueChoice : {
            options : [{
                effect : Effect;
            }];
        };
        #pickASide : {
            options : [{
                sideId : Text;
            }];
        };
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
                #skill : {
                    skill : Skill.Skill;
                    target : {
                        #position : FieldPosition.FieldPosition;
                    };
                    duration : Duration;
                    total : Nat;
                };
            };
            options : [{
                bidValue : Nat;
            }];
        };
        #noEffect;
    };

};
