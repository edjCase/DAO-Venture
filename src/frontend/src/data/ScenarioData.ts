import { Principal } from "@dfinity/principal";

// Assuming necessary types like Principal are defined elsewhere
export type ScenarioTeamIndex = number;
export type ScenarioPlayerIndex = number;

export type OtherTeam =
    | { 'opposing': null }
    | { 'other': ScenarioTeamIndex };

export type Target =
    | { 'league': null }
    | { 'teams': ScenarioTeamIndex[] }
    | { 'players': ScenarioPlayerIndex[] };

export type Duration =
    | { 'indefinite': null }
    | { 'matches': number };

export type Effect =
    | { 'trait': { target: Target; traitId: string; duration: Duration } }
    | { 'alliance': OtherTeam }
    | { 'rivalry': OtherTeam }
    | { 'points': number }
    | { 'chance': { probability: number; effects: Effect[] } };

export interface ScenarioTeam {
    // Define other filters/weights as needed
}

export interface ScenarioPlayer {
    team: ScenarioTeamIndex;
    // Define weights as needed
}

export interface ScenarioOption {
    title: string;
    description: string;
    entropy: number;
    effects: Effect[];
}

export interface Scenario {
    id: string;
    title: string;
    description: string;
    options: ScenarioOption[];
    otherTeams: ScenarioTeam[];
    players: ScenarioPlayer[];
}

export interface Instance {
    scenario: Scenario;
    teamId: Principal;
    opposingTeamId: Principal;
    otherTeamIds: Principal[];
    playerIds: number[];
}

export interface InstanceWithChoice extends Instance {
    choice: number;
}

export let scenarios: Scenario[] = [
    {
        id: "MYSTIC_PLAYBOOK_CONUNDRUM",
        title: "The Mystic Playbook Conundrum",
        description: "Amidst the ruins of an ancient sports complex, {Team0} uncovers the Mystic Playbook, said to be imbued with the wisdom of DAOball's greatest minds but rumored to be cursed.",
        otherTeams: [],
        players: [{ team: 0 }],
        options: [
            {
                title: "Open for {Team0}",
                description: "{Team0} decides to brave the potential curse and gain strategic advantage by opening the Mystic Playbook themselves.",
                entropy: 10,
                effects: [
                    { 'trait': { target: { 'teams': [0] }, traitId: "CURSED", duration: { 'indefinite': null } } }
                ]
            },
            {
                title: "Sell to {Team1}",
                description: "{Team0} sells the Mystic Playbook to {Team1}, transferring the risk of the curse and the chance of becoming rivals if {Team1} is afflicted.",
                entropy: -5,
                effects: [
                    {
                        'chance': {
                            probability: 0.3, effects: [
                                { 'trait': { target: { 'teams': [1] }, traitId: "CURSED", duration: { 'indefinite': null } } },
                                { 'rivalry': [0, 1] }
                            ]
                        }
                    }
                ]
            },
            {
                title: "Secure and Research",
                description: "{Team0} secures the playbook and invests in researching it to mitigate the risk of the curse while attempting to unlock its secrets.",
                entropy: 0,
                effects: [
                    { 'trait': { target: { 'teams': [0] }, traitId: "MODERATE_ENHANCEMENT", duration: { 'matches': 3 } } }
                ]
            },
        ]
    };
];