import { ScenarioTemplate } from "../models/Scenario";


export let scenarios: ScenarioTemplate[] = [
    {
        id: "MYSTIC_PLAYBOOK_CONUNDRUM",
        title: "The Mystic Playbook Conundrum",
        description: "Amidst the ruins of an ancient sports complex, {ScenarioTeam} uncovers the Mystic Playbook, said to be imbued with the wisdom of DAOball's greatest minds but rumored to be cursed.",
        otherTeams: [],
        players: [{ team: { scenarioTeam: null } }],
        options: [
            {
                title: "Open for {ScenarioTeam}",
                description: "{ScenarioTeam} decides to brave the potential curse and gain strategic advantage by opening the Mystic Playbook themselves.",
                effect: {
                    'allOf': [
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: 10 } },
                        { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "CURSED", duration: { 'indefinite': null } } }
                    ]
                }
            },
            {
                title: "Sell to {OpposingTeam}",
                description: "{ScenarioTeam} sells the Mystic Playbook to {OpposingTeam}, transferring the risk of the curse and the chance of becoming rivals if {OpposingTeam} is afflicted.",
                effect: {
                    'allOf': [
                        { 'entropy': { team: { 'scenarioTeam': null }, delta: -5 } },
                        {
                            'oneOf': [
                                [
                                    3,
                                    {
                                        'allOf': [
                                            { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "CURSED", duration: { 'indefinite': null } } },
                                            { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }, { 'opposingTeam': null }] }, traitId: "RIVAL", duration: { 'indefinite': null } } }
                                        ]
                                    }
                                ],
                                [
                                    7,
                                    { 'noEffect': null }
                                ]
                            ]
                        }
                    ]
                }
            },
            {
                title: "Secure and Research",
                description: "{ScenarioTeam} secures the playbook and invests in researching it to mitigate the risk of the curse while attempting to unlock its secrets.",
                effect: { 'trait': { target: { 'teams': [{ 'scenarioTeam': null }] }, traitId: "MODERATE_ENHANCEMENT", duration: { 'matches': 3 } } }
            },
        ]
    }
];