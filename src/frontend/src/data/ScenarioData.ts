import { MetaEffect, ScenarioOptionWithEffect } from "../ic-agent/declarations/league";


export interface Scenario {
    'title': string,
    'description': string,
    'metaEffect': MetaEffect,
    'options': Array<ScenarioOptionWithEffect>,
}


export let scenarios: Scenario[] = [
    {
        title: "Energy Required",
        description: "The league needs at least 4 more energy for operations or the whole league will gain entropy.",
        options: [
            {
                title: "Give",
                description: "Gives the league 1 energy but will cause sluggishness in the next match for your team.",
                energyCost: BigInt(0),
                effect: {
                    allOf: [
                        {
                            entropy: {
                                target: { teams: [{ choosingTeam: null }] },
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
                description: "Give no energy.",
                energyCost: BigInt(0),
                effect: {
                    entropy: {
                        target: { teams: [{ choosingTeam: null }] },
                        delta: BigInt(1), // Increase entropy from not contributing
                    }
                },
            },
            {
                title: "Try Optimizing",
                description: "Give no energy but try to reduce energy consumption, but no guarentees.",
                energyCost: BigInt(0),
                effect: {
                    noEffect: null
                },
            },
            {
                title: "Pay",
                description: "Pay 1 energy to the league.",
                energyCost: BigInt(1),
                effect: { noEffect: null },
            }
        ],
        metaEffect: {
            threshold: {
                threshold: BigInt(4), // Total energy contribution threshold
                over: {
                    entropy: {
                        target: { league: null },
                        delta: BigInt(-1), // Additional decrease in entropy for contributing teams if threshold is met
                    }
                },
                under: {
                    entropy: {
                        target: { league: null },
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
                                [BigInt(0), BigInt(1)],
                            ]
                        }
                    },
                    { value: { fixed: BigInt(1) } },
                ],
            },
        },
    },
    {
        title: "Training bid",
        description: "Bid to boost your pitcher's throwing power through specialized training. The amount of training each pitcher receives will be proportional to their bid's size relative to the total bids placed.",
        options: [
            {
                title: "No bid",
                description: "No bid.",
                energyCost: BigInt(0),
                effect: { noEffect: null },
            },
            {
                title: "Bid 1",
                description: "Bid 1 energy",
                energyCost: BigInt(1),
                effect: { noEffect: null },
            },
            {
                title: "Bid 2",
                description: "Bid 2 energy",
                energyCost: BigInt(2),
                effect: { noEffect: null },
            },
            {
                title: "Bid 3",
                description: "Bid 3 energy",
                energyCost: BigInt(3),
                effect: { noEffect: null },
            },
        ],
        metaEffect: {
            proportionalBid: {
                prize: {
                    amount: BigInt(10),
                    kind: {
                        skill: {
                            skill: { throwingPower: null },
                            target: { position: { pitcher: null } },
                            duration: { indefinite: null }
                        }
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
        title: "Training lottery",
        description: "Enter the lottery to win +3 speed training for your first baseman. The more tickets you buy, the higher your chances of winning the training boost.",
        options: [
            {
                title: "No ticket",
                description: "No ticket.",
                energyCost: BigInt(0),
                effect: { noEffect: null },
            },
            {
                title: "1 ticket",
                description: "1 ticket",
                energyCost: BigInt(1),
                effect: { noEffect: null },
            },
            {
                title: "2 tickets",
                description: "2 tickets",
                energyCost: BigInt(2),
                effect: { noEffect: null },
            },
            {
                title: "3 tickets",
                description: "3 tickets",
                energyCost: BigInt(3),
                effect: { noEffect: null },
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
        title: "Scavenge",
        description: "Scavenge for resources to improve your team.",
        options: [
            {
                title: "Play it safe",
                description: "Don't scavenge, can't risk it.",
                energyCost: BigInt(0),
                effect: { noEffect: null },
            },
            {
                title: "Scavenge",
                description: "Scavenge for energy and knowledge but risk injury.",
                energyCost: BigInt(0),
                effect: {
                    oneOf: [
                        [
                            BigInt(1),
                            {
                                energy: {
                                    team: { choosingTeam: null },
                                    value: { flat: BigInt(2) },
                                }
                            }
                        ],
                        [
                            BigInt(1),
                            {
                                energy: {
                                    team: { choosingTeam: null },
                                    value: { flat: BigInt(3) },
                                }
                            }
                        ],
                        [
                            BigInt(1),
                            {
                                skill: {
                                    target: { positions: [{ teamId: { choosingTeam: null }, position: { firstBase: null } }] }, // TODO randomize position
                                    skill: { speed: null }, // TODO randomize skill
                                    delta: BigInt(1),
                                    duration: { indefinite: null },
                                }
                            }
                        ],
                        [
                            BigInt(2),
                            {
                                injury: {
                                    target: { positions: [{ teamId: { choosingTeam: null }, position: { firstBase: null } }] }, // TODO randomize position
                                    injury: { brokenArm: null }, // TODO randomize injury
                                }
                            }
                        ],
                    ]
                },
            },
        ],
        metaEffect: {
            noEffect: null,
        }
    }
];