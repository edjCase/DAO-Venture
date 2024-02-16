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
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "INFORMATION", duration: { 'matches': BigInt(1) } } }
                                ],
                                [
                                    // Fake plant, negative effect
                                    BigInt(4), // TODO this should be affected by the opposing team chaos score
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "BAD_INFORMATION", duration: { 'matches': BigInt(1) } } }
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
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: BigInt(1) } },
                        { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "BOOSTED_RESOURCES", duration: { 'matches': BigInt(2) } } },
                        { 'trait': { target: { 'players': [BigInt(0)] }, traitId: "MORAL_BOOST", duration: { 'matches': BigInt(2) } } },
                        { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "STRINGS_ATTACHED", duration: { 'indefinite': null } } }
                    ]
                }
            },
            {
                title: "Politely Decline. Side with {Player1}",
                description: "Decline the offer to maintain autonomy, potentially missing out on resources but keeping the team's integrity.",
                effect: {
                    'allOf': [
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: BigInt(-1) } },
                        { 'trait': { target: { 'players': [BigInt(0)] }, traitId: "MORAL_BOOST", duration: { 'matches': BigInt(2) } } }
                    ]
                }
            },
            {
                title: "Investigate the Sponsor",
                description: "Take time to investigate the sponsor's background and intentions before making a decision.",
                effect: {
                    'allOf': [
                        {
                            'oneOf': [
                                [
                                    BigInt(6),
                                    { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "VALUABLE_INSIGHTS", duration: { 'matches': BigInt(1) } } }
                                ],
                                [
                                    BigInt(4),
                                    { 'noEffect': null }
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
                    'oneOf': [
                        [
                            BigInt(4),
                            { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "SUCCESSFUL_SWAP", duration: { 'matches': BigInt(1) } } }
                        ],
                        [
                            BigInt(6),
                            { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "CAUGHT_SWAPPING", duration: { 'matches': BigInt(1) } } }
                        ]
                    ]
                }
            },
            {
                title: "Play with Damaged Gear",
                description: "Decide to play with the damaged equipment, potentially impacting performance but maintaining integrity.",
                effect: { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "COMPROMISED_PERFORMANCE", duration: { 'matches': BigInt(1) } } }
            },
            {
                title: "Incur Debt for Replacements",
                description: "Opt to quickly replace the equipment by incurring a debt, ensuring performance but at a future cost.",
                effect: { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "DEBT", duration: { 'matches': BigInt(3) } } }
            }
        ]
    }
];