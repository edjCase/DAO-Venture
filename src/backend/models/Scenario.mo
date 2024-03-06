import Skill "Skill";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Bool "mo:base/Bool";
import Trait "Trait";
import MatchAura "MatchAura";
import Team "Team";
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
            teamId : Principal;
            delta : Int;
        };
        #energy : {
            teamId : Principal;
            delta : Int;
        };
    };

    public type EffectOutcome = PlayerEffectOutcome or TeamEffectOutcome;

    public type TargetInstance = {
        #league;
        #teams : [Principal];
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
        effect : {
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
            #simple;
        };
    };

    public type ResolvedScenario = Scenario and {
        teamChoices : [{
            teamId : Principal;
            option : Nat8;
        }];
        effectOutcomes : [EffectOutcome];
    };

    // Freerider Problem - Contribute or not, need to reach threshold
    // Tragedy of the Commons - Limited resources, take or not, need to NOT reach threshold
    // Pick a side or stay neutral
    // Risk/reward (indenpendent) - Every team can do X, with a random chance of failure/success
    // Secret bidding - Every team can bid X, with the highest bidder getting a bonus, or proportional bonuses from fixed pool
    public func a() : [Scenario] {
        [
            {
                id = "SURGE_CRISIS_OPENING_CEREMONY";
                title = "Surge Crisis at the Opening Ceremony";
                description = "The DAOball opening ceremony is under threat due to an unprecedented energy surge. Teams, as beings of energy, face a dilemma: contribute their energy to stabilize the grid or conserve it for the upcoming matches.";
                options = [
                    {
                        title = "Contribute";
                        description = "Contribute energy to stabilize the grid.";
                        effect = #allOf([
                            #entropy({
                                team = #choosingTeam;
                                delta = -1; // Lower entropy as aligning with league values
                            }),
                            #skill({
                                target = #teams([#choosingTeam]);
                                skill = #speed;
                                duration = #matches(1);
                                delta = -1; // Temporary skill reduction due to energy contribution
                            }),
                        ]);
                    },
                    {
                        title = "Conserve";
                        description = "Conserve your energy for upcoming matches.";
                        effect = #entropy({
                            team = #choosingTeam;
                            delta = 1; // Increase entropy from not contributing
                        });
                    },
                    {
                        title = "Convince fans to reduce energy";
                        description = "Convince fans to reduce their energy consumption, at the risk of backlash.";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(-1); // Spend tokens to convince fans
                        });
                    },
                ];
                effect = #threshold({
                    threshold = 4; // Total energy contribution threshold
                    over = #entropy({
                        team = #choosingTeam;
                        delta = -1; // Additional decrease in entropy for contributing teams if threshold is met
                    });
                    under = #entropy({
                        team = #choosingTeam;
                        delta = 1; // Increase in entropy for all teams if threshold is not met
                    });
                    options = [
                        { value = #fixed(1) },
                        { value = #fixed(0) },
                        {
                            value = #weightedChance([
                                (1, 1),
                                (1, 0),
                            ]);
                        },
                    ];
                });
            },
            {
                id = "TRAINING_BID";
                title = "Training bid";
                description = "Training bid";
                options = [
                    {
                        title = "No bid";
                        description = "No bid.";
                        effect = #noEffect;
                    },
                    {
                        title = "Bid 1";
                        description = "Bid 1 energy";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(1);
                        });
                    },
                    {
                        title = "Bid 2";
                        description = "Bid 2 energy";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(2);
                        });
                    },
                    {
                        title = "Bid 3";
                        description = "Bid 3 energy";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(3);
                        });
                    },
                ];
                effect = #proportionalBid({
                    prize = #skill({
                        skill = #throwingPower;
                        target = #position(#pitcher);
                        duration = #indefinite;
                        total = 10;
                    });
                    options = [
                        {
                            bidValue = 0;
                        },
                        {
                            bidValue = 1;
                        },
                        {
                            bidValue = 2;
                        },
                        {
                            bidValue = 3;
                        },
                    ];
                });
            },
            {
                id = "TRAINING_LOTTERY";
                title = "Training lottery";
                description = "Training lottery";
                options = [
                    {
                        title = "No ticket";
                        description = "No ticket.";
                        effect = #noEffect;
                    },
                    {
                        title = "1 ticket";
                        description = "1 ticket";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(-1);
                        });
                    },
                    {
                        title = "2 tickets";
                        description = "2 tickets";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(-2);
                        });
                    },
                    {
                        title = "3 tickets";
                        description = "3 tickets";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(-3);
                        });
                    },
                ];
                effect = #lottery({
                    prize = #skill({
                        skill = #speed;
                        target = #players([#position(#firstBase)]);
                        duration = #indefinite;
                        delta = 3;
                    });
                    options = [
                        {
                            tickets = 0;
                        },
                        {
                            tickets = 1;
                        },
                        {
                            tickets = 2;
                        },
                        {
                            tickets = 3;
                        },
                    ];
                });
            },
            {
                id = "TRAINING_SECRET_BIDDING";
                title = "Training secret bidding";
                description = "Training secret bidding";
                options = [
                    {
                        title = "No bid";
                        description = "No bid.";
                        effect = #noEffect;
                    },
                    {
                        title = "Bid 1";
                        description = "Bid 1 energy";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(1);
                        });
                    },
                    {
                        title = "Bid 2";
                        description = "Bid 2 energy";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(2);
                        });
                    },
                    {
                        title = "Bid 3";
                        description = "Bid 3 energy";
                        effect = #energy({
                            team = #choosingTeam;
                            value = #flat(3);
                        });
                    },
                ];
                effect = #proportionalBid({
                    prize = #skill({
                        skill = #throwingPower;
                        target = #position(#pitcher);
                        duration = #indefinite;
                        total = 10;
                    });
                    options = [
                        {
                            bidValue = 0;
                        },
                        {
                            bidValue = 1;
                        },
                        {
                            bidValue = 2;
                        },
                        {
                            bidValue = 3;
                        },
                    ];
                });
            },
            {
                id = "RESOURCE_MANAGEMENT_CHALLENGE";
                title = "Resource Management Challenge";
                description = "An unexpected shortage of essential resources puts all teams in a tight spot. How will you manage?";
                options = [
                    {
                        title = "Share Resources";
                        description = "Share your scarce resources with the league, promoting unity.";
                        effect = #allOf([
                            #entropy({
                                team = #choosingTeam;
                                delta = -1; // Decrease entropy for promoting unity
                            }),
                            #energy({
                                team = #choosingTeam;
                                value = #flat(-1); // Spend tokens to share resources
                            }),
                        ]);
                    },
                    {
                        title = "Conserve Resources";
                        description = "Keep your resources, ensuring your team's stability.";
                        effect = #entropy({
                            team = #choosingTeam;
                            delta = 1; // Increase entropy for being selfish
                        });
                    },
                ];
                effect = #threshold({
                    threshold = 4; // Total resources shared threshold
                    over = #entropy({
                        team = #choosingTeam;
                        delta = -1; // Additional decrease in entropy for sharing teams if threshold is met
                    });
                    under = #entropy({
                        team = #choosingTeam;
                        delta = 1; // Increase in entropy for all teams if threshold is not met
                    });
                    options = [
                        { value = #fixed(1) },
                        { value = #fixed(0) },
                    ];
                });
            },
        ];
    };

};
