import { ScenarioTemplate } from "../models/Scenario";


export let scenarios: ScenarioTemplate[] = [
    {
        id: "NOTEBOOK_CONUNDRUM",
        title: "The Notebook Conundrum",
        description: "On a walk around the stands, {Player0} runs across a notebook with strategies from {OpposingTeam}. Could be useful, or could be a fake plant by {OpposingTeam}.",
        otherTeams: [],
        players: [{ team: { scenarioTeam: null } }],
        effect: { 'noEffect': null },
        options: [
            {
                title: "Study it",
                description: "Choose to steal the notebook to try get a benefit",
                effect: {
                    'allOf': [
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: BigInt(1) } },
                        {
                            'oneOf': [
                                [
                                    // Useful, positive effect
                                    BigInt(6), // TODO this should be affected by the opposing team order score
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "STRATEGIC_ADVANTAGE", duration: { 'matches': BigInt(1) } } }
                                ],
                                [
                                    // Fake plant, negative effect
                                    BigInt(4), // TODO this should be affected by the opposing team chaos score
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "STRATEGIC_DISADVANTAGE", duration: { 'matches': BigInt(1) } } }
                                ]
                            ]
                        }
                    ]
                }
            },
            {
                title: "Give back without reading it",
                description: "Choose to give the notebook back to {OpposingTeam}, but risk them thinking you've read it.",
                effect: {
                    'allOf': [
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: BigInt(-1) } },
                        {
                            'oneOf': [
                                [
                                    BigInt(9), // TODO this should be affected by the opposing team order score
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }, { 'opposingTeam': null }] }, traitId: "ALLIES", duration: { 'matches': BigInt(1) } } }// TODO needs trait args for specifying the ally team
                                ],
                                [
                                    BigInt(1), // TODO this should be affected by the opposing team chaos score
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }, { 'opposingTeam': null }] }, traitId: "RIVALS", duration: { 'matches': BigInt(1) } } } // TODO needs trait args for specifying the rival team
                                ]
                            ]
                        }
                    ]
                }
            },
            {
                title: "Leave it Alone",
                description: "Decide not to interfere with the notebook, respecting the sanctity of strategy and avoiding potential traps.",
                effect: { 'entropy': { team: { 'scenarioTeam': null }, delta: BigInt(-2) } }
            }
        ]
    },
    {
        id: "MYSTERIOUS_SPONSOR",
        title: "The Mysterious Sponsor",
        description: "A wealthy fan offers substantial support to your team, but their intentions are unclear. {Player0} and {Player1} have different opinions on the matter.",
        otherTeams: [],
        players: [{ team: { scenarioTeam: null } }, { team: { scenarioTeam: null } }],
        effect: { 'noEffect': null },
        options: [
            {
                title: "Accept the Offer. Side with {Player0}",
                description: "Embrace the sponsor's support, hoping for a boost but risking hidden strings attached.",
                effect: {
                    'allOf': [
                        { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "BOOSTED_RESOURCES", duration: { 'matches': BigInt(2) } } },
                        { 'trait': { target: { 'players': [BigInt(0)] }, traitId: "MORALE_BOOST", duration: { 'matches': BigInt(1) } } },
                        { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "STRINGS_ATTACHED", duration: { 'indefinite': null } } }
                    ]
                }
            },
            {
                title: "Politely Decline. Side with {Player1}",
                description: "Decline the offer to maintain autonomy, potentially missing out on resources but keeping the team's integrity.",
                effect: {
                    'allOf': [
                        { 'trait': { target: { 'players': [BigInt(0)] }, traitId: "MORALE_BOOST", duration: { 'matches': BigInt(1) } } }
                    ]
                }
            },
            {
                title: "Accept the Offer, but try to dig up dirt on them to get a better deal.",
                description: "The team delves into the shadows, hoping to uncover leverage against the sponsor.",
                effect: {
                    'allOf': [
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: BigInt(2) } },
                        {
                            'oneOf': [
                                [
                                    // Caught, negative effect, no deal
                                    BigInt(4),
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "CHEATER", duration: { 'indefinite': null } } }
                                ],
                                [
                                    // Not caught, accept deal
                                    BigInt(6),
                                    {
                                        'allOf': [
                                            { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "BOOSTED_RESOURCES", duration: { 'matches': BigInt(2) } } },
                                            {
                                                'oneOf': [
                                                    [
                                                        // No dirt found, accept deal as is
                                                        BigInt(6),
                                                        { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "STRINGS_ATTACHED", duration: { 'indefinite': null } } }
                                                    ],
                                                    [
                                                        // Found dirt, leverage for better deal
                                                        BigInt(4),
                                                        { 'noEffect': null }
                                                    ]
                                                ]
                                            }
                                        ]
                                    }
                                ]

                            ]
                        }
                    ]

                }
            }
        ]
    },
    {
        id: "DAMAGED_EQUIPMENT_DILEMMA",
        title: "The Damaged Equipment Dilemma",
        description: "In a playful tussle for the last energy bar, {Player0} and {Player1} accidentally send a stack of bats clattering to the ground, only to find them splintered beyond repair, they better figure out how to get out of this predicament.",
        otherTeams: [],
        players: [{ 'team': { 'scenarioTeam': null } }, { 'team': { 'scenarioTeam': null } }],
        effect: { 'trait': { target: { 'players': [BigInt(0), BigInt(1)] }, traitId: "LOW_MORALE", duration: { 'matches': BigInt(1) } } },
        options: [
            {
                title: "Attempt a Swap",
                description: "Try to swap the damaged equipment with the opposing team, risking getting caught and facing penalties.",
                effect: {
                    'allOf': [
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: BigInt(1) } },
                        {
                            'oneOf': [
                                [
                                    BigInt(5),
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "STRATEGIC_ADVANTAGE", duration: { 'matches': BigInt(1) } } }
                                ],
                                [
                                    BigInt(5),
                                    {
                                        'allOf': [
                                            { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "STRATEGIC_DISADVANTAGE", duration: { 'matches': BigInt(1) } } },
                                            { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "CHEATER", duration: { 'indefinite': null } } }
                                        ]
                                    }
                                ]
                            ]
                        }
                    ]
                }
            },
            {
                title: "Play with Damaged Gear",
                description: "Decide to play with the damaged equipment, potentially impacting performance but maintaining integrity.",
                effect: { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "STRATEGIC_DISADVANTAGE", duration: { 'matches': BigInt(1) } } }
            },
            {
                title: "Incur Debt for Replacements",
                description: "Opt to quickly replace the equipment by incurring a debt, ensuring performance but at a future cost.",
                effect: { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "DEBT", duration: { 'matches': BigInt(3) } } }
            }
        ]
    },
    {
        id: "DEBT_COLLECTOR",
        title: "The Debt Collector",
        description: "As the team huddled around the strategy board, a rift in reality crackled open, and out stepped a being made of shadows and whispers. It pointed a nebulous finger at {Player0}, murmuring about a 'debt' owed, leaving the team to ponder their next move.",
        otherTeams: [],
        players: [{ 'team': { 'scenarioTeam': null } }, { 'team': { 'scenarioTeam': null } }],
        effect: { 'noEffect': null },
        // requirement: { 'trait': "DEBT" }, TODO
        options: [
            {
                title: "Surrender to Fate",
                description: "Reluctantly agree to hand over {Player0}, hoping the mystical figure's promise of 'settling the cosmic scales' brings unforeseen benefits.",
                effect: {
                    'allOf': [
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: BigInt(-2) } },
                        { 'trait': { target: { 'players': [BigInt(0)] }, traitId: "OUT_OF_COMMISSION", duration: { 'matches': BigInt(1) } } },
                        {
                            'oneOf': [
                                [
                                    // Break their leg
                                    BigInt(3),
                                    { 'injury': { target: { 'players': [BigInt(0)] }, injury: { brokenLeg: null } } }
                                ],
                                [
                                    // Just scare them
                                    BigInt(7),
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "LOW_MORALE", duration: { 'matches': BigInt(1) } } }
                                ]
                            ]
                        }
                    ]
                }
            },
            {
                title: "Defy the Collector",
                description: "With a defiant cheer, the team refuses, accepting the 'Price on Head' trait, ready to face whatever whimsical challenges come their way.",
                effect: { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "PRICE_ON_HEAD", duration: { 'matches': BigInt(1) } } }
            },
            {
                title: "Bargain with Whimsy",
                description: "Engage the collector in a bizarre contest of riddles and games, hoping to erase the debt without any losses.",
                effect: {
                    'oneOf': [
                        [
                            BigInt(3),
                            { 'removeTrait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "DEBT" } }
                        ],
                        [
                            BigInt(7),
                            { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "PRICE_ON_HEAD", duration: { 'matches': BigInt(1) } } }
                        ]
                    ]
                }
            }
        ]
    }
];