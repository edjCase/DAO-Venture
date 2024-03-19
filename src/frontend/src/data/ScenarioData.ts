import { MetaEffect, ScenarioOptionWithEffect } from "../ic-agent/declarations/league";


export interface Scenario {
    'id': string,
    'title': string,
    'description': string,
    'metaEffect': MetaEffect,
    'options': Array<ScenarioOptionWithEffect>,
}


export let scenarios: Scenario[] = [
    {
        id: "SURGE_CRISIS_OPENING_CEREMONY",
        title: "Surge Crisis at the Opening Ceremony",
        description: "The DAOball opening ceremony is under threat due to an unprecedented energy surge. Teams, as beings of energy, face a dilemma: contribute their energy to stabilize the grid or conserve it for the upcoming matches. At least 4 teams need to contribute their energy to stabilize the grid.",
        options: [
            {
                title: "Contribute",
                description: "Contribute energy to stabilize the grid. This will give the league 1 energy but will cause sluggishness in the next match for your team.",
                effect: {
                    allOf: [
                        {
                            entropy: {
                                team: { choosingTeam: null },
                                delta: BigInt(-1), // Lower entropy as aligning with league values
                            }
                        },
                        {
                            skill: {
                                target: { teams: [{ choosingTeam: null }] },
                                skill: { speed: null },
                                duration: { matches: BigInt(1) },
                                delta: BigInt(-1), // Temporary skill reduction due to energy contribution
                            }
                        },
                    ]
                },
            },
            {
                title: "Conserve",
                description: "Conserve your energy for upcoming matches, but risk the opening ceremony not having enough power.",
                effect: {
                    entropy: {
                        team: { choosingTeam: null },
                        delta: BigInt(1), // Increase entropy from not contributing
                    }
                },
            },
            {
                title: "Convince fans to reduce energy",
                description: "Convince fans to reduce their energy consumption, at the risk of backlash. This will not affect your team's energy, but could do nothing.",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(-1) }, // Spend tokens to convince fans
                    }
                },
            },
        ],
        metaEffect: {
            threshold: {
                threshold: BigInt(4), // Total energy contribution threshold
                over: {
                    entropy: {
                        team: { choosingTeam: null },
                        delta: BigInt(-1), // Additional decrease in entropy for contributing teams if threshold is met
                    }
                },
                under: {
                    entropy: {
                        team: { choosingTeam: null },
                        delta: BigInt(1), // Increase in entropy for all teams if threshold is not met
                    }
                },
                options: [
                    { value: { fixed: BigInt(1) } },
                    { value: { fixed: BigInt(0) } },
                    {
                        value: {
                            weightedChance: [
                                [BigInt(1), BigInt(1)],
                                [BigInt(1), BigInt(0)],
                            ]
                        }
                    },
                ],
            },
        },
    },
    {
        id: "TRAINING_BID",
        title: "Training bid",
        description: "Training bid",
        options: [
            {
                title: "No bid",
                description: "No bid.",
                effect: { noEffect: null },
            },
            {
                title: "Bid 1",
                description: "Bid 1 energy",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(1) },
                    }
                },
            },
            {
                title: "Bid 2",
                description: "Bid 2 energy",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(2) },
                    }
                },
            },
            {
                title: "Bid 3",
                description: "Bid 3 energy",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(3) },
                    }
                },
            },
        ],
        metaEffect: {
            proportionalBid: {
                prize: {
                    skill: {
                        skill: { throwingPower: null },
                        target: { position: { pitcher: null } },
                        duration: { indefinite: null },
                        total: BigInt(10),
                    }
                },
                options: [
                    {
                        bidValue: BigInt(0),
                    },
                    {
                        bidValue: BigInt(1),
                    },
                    {
                        bidValue: BigInt(2),
                    },
                    {
                        bidValue: BigInt(3),
                    },
                ],
            },
        },
    },
    {
        id: "TRAINING_LOTTERY",
        title: "Training lottery",
        description: "Training lottery",
        options: [
            {
                title: "No ticket",
                description: "No ticket.",
                effect: { noEffect: null },
            },
            {
                title: "1 ticket",
                description: "1 ticket",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(-1) },
                    }
                },
            },
            {
                title: "2 tickets",
                description: "2 tickets",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(-2) },
                    }
                },
            },
            {
                title: "3 tickets",
                description: "3 tickets",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(-3) },
                    }
                },
            },
        ],
        metaEffect: {
            lottery: {
                prize: {
                    skill: {
                        skill: { speed: null },
                        target: { positions: [{ teamId: { choosingTeam: null }, position: { firstBase: null } }] },
                        duration: { indefinite: null },
                        delta: BigInt(3),
                    }
                },
                options: [
                    {
                        tickets: BigInt(0),
                    },
                    {
                        tickets: BigInt(1),
                    },
                    {
                        tickets: BigInt(2),
                    },
                    {
                        tickets: BigInt(3),
                    },
                ],
            },
        },
    },
    {
        id: "TRAINING_SECRET_BIDDING",
        title: "Training secret bidding",
        description: "Training secret bidding",
        options: [
            {
                title: "No bid",
                description: "No bid.",
                effect: { noEffect: null },
            },
            {
                title: "Bid 1",
                description: "Bid 1 energy",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(1) },
                    }
                },
            },
            {
                title: "Bid 2",
                description: "Bid 2 energy",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(2) },
                    }
                },
            },
            {
                title: "Bid 3",
                description: "Bid 3 energy",
                effect: {
                    energy: {
                        team: { choosingTeam: null },
                        value: { flat: BigInt(3) },
                    }
                },
            },
        ],
        metaEffect: {
            proportionalBid: {
                prize: {
                    skill: {
                        skill: { throwingPower: null },
                        target: { position: { pitcher: null } },
                        duration: { indefinite: null },
                        total: BigInt(10),
                    }
                },
                options: [
                    {
                        bidValue: BigInt(0),
                    },
                    {
                        bidValue: BigInt(1),
                    },
                    {
                        bidValue: BigInt(2),
                    },
                    {
                        bidValue: BigInt(3),
                    },
                ],
            },
        },
    },
    {
        id: "RESOURCE_MANAGEMENT_CHALLENGE",
        title: "Resource Management Challenge",
        description: "An unexpected shortage of essential resources puts all teams in a tight spot. How will you manage?",
        options: [
            {
                title: "Share Resources",
                description: "Share your scarce resources with the league, promoting unity.",
                effect: {
                    allOf: [
                        {
                            entropy: {
                                team: { choosingTeam: null },
                                delta: BigInt(-1), // Decrease entropy for promoting unity
                            }
                        },
                        {
                            energy: {
                                team: { choosingTeam: null },
                                value: { flat: BigInt(-1) }, // Spend tokens to share resources
                            }
                        },
                    ]
                },
            },
            {
                title: "Conserve Resources",
                description: "Keep your resources, ensuring your team's stability.",
                effect: {
                    entropy: {
                        team: { choosingTeam: null },
                        delta: BigInt(1), // Increase entropy for being selfish
                    }
                },
            },
        ],
        metaEffect: {
            threshold: {
                threshold: BigInt(4), // Total resources shared threshold
                over: {
                    entropy: {
                        team: { choosingTeam: null },
                        delta: BigInt(-1), // Additional decrease in entropy for sharing teams if threshold is met
                    }
                },
                under: {
                    entropy: {
                        team: { choosingTeam: null },
                        delta: BigInt(1), // Increase in entropy for all teams if threshold is not met
                    }
                },
                options: [
                    { value: { fixed: BigInt(1) } },
                    { value: { fixed: BigInt(0) } },
                ],
            },
        },
    }


];