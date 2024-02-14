import { MatchAura } from "../models/MatchAura";
import { Skill } from "../models/Scenario";
import { Trait } from "../models/Trait";

export type Target =
    | { team: number; }
    | { player: number; }
    | { matchGroup: number; match: number; }
    | { league: null; };

export type SkillEffect = {
    target: Target;
    skill: Skill;
    value: number;
    permanent: boolean;
};

export type TraitEffect = {
    target: Target;
    trait: Trait;
    permanent: boolean;
};

export type AuraEffect = {
    matchGroup: number;
    match: number;
    aura: MatchAura;
};

export type PointsEffect = {
    points: number;
};

export type Effect =
    | { 'skill': SkillEffect }
    | { 'trait': TraitEffect }
    | { 'aura': AuraEffect }
    | { 'points': PointsEffect }
    | { 'oneOf': { 'effect': Effect, 'weight': number }[] };

export type Requirement =
    | {
        'skill': {
            'skill': Skill;
            'value': number;
        }
    }
    | {
        'entropy': {
            'min': number | undefined;
            'max': number | undefined;
        }
    }
    | { 'trait': Trait };

export type ScenarioOption = {
    name: string;
    description: string;
    requirements: Requirement[];
    entropy: number; // Negative for order, positive for chaos
    effects: Effect[];
};

export type Scenario = {
    id: number;
    name: string;
    description: string;
    options: ScenarioOption[];
    weight: {
        value: number;
        affectedBy: {
            requirement: Requirement;
            weight: number;
        } | undefined;
    }
};

export const scenrios: Scenario[] = [
    {
        id: 1,
        name: "The Datapad Dilemma",
        description: "Amidst the ruins of an ancient sports complex, {Player1} uncovers a pre-collapse datapad, brimming with DAOball strategies lost to time.",
        options: [
            {
                name: "Erase the Past",
                description: "With a heavy heart, {Player1} decides that some advantages are too perilous to pursue.",
                entropy: 10, // High chaos
                effects: [
                    {
                        'trait': {
                            target: { 'player': 1 },
                            trait: { 'madeOfGlass': null }, // TODO - This is a placeholder
                            permanent: true
                        }
                    }],
                requirements: []
            },
            {
                name: "Empower the Team",
                description: "Torn between loyalty and fairness, {Player1} opts to share the datapad's secrets with the {Team1} alone.",
                entropy: -5, // Low order
                effects: [
                    {
                        'trait': {
                            target: { 'player': 1 },
                            trait: { 'inspiring': null }, // TODO - This is a placeholder
                            permanent: true
                        }
                    },
                    {
                        'skill': {
                            target: { 'team': 1 },
                            skill: { 'speed': null }, // TODO - This is a placeholder
                            value: 5,
                            permanent: false
                        }
                    }
                ],
                requirements: []
            },
            {
                name: "Enlighten the League",
                description: "Seeing a chance to elevate the game itself, {Player1} broadcasts the datapad's contents across the league.",
                entropy: -20, // High order
                effects: [
                    {
                        'aura': {
                            matchGroup: 0,
                            match: 0,
                            aura: { 'explodingBalls': null } // TODO - This is a placeholder
                        }
                    },
                    {
                        'trait': {
                            target: { 'player': 1 },
                            trait: { 'jackOfAllTrades': null }, // TODO - This is a placeholder
                            permanent: true
                        }
                    }
                ],
                requirements: []
            }
        ],
        weight: {
            value: 1,
            affectedBy: undefined
        }
    },
    {
        id: 2,
        name: "The Galactic Gamble",
        description: "In a twist of fate, {Team1} stumbles upon an ancient relic on the eve of a crucial match: the Celestial Bat, imbued with the power to sway the tides of any game. However, the relic comes with a warning inscribed in starlight, 'To wield such power, one must be willing to dance with the cosmos itself, for the bat's boon may come with unforeseen consequences.'",
        options: [
            {
                name: "Embrace the Celestial Power",
                description: "Deciding to harness the bat's ancient energy, {Team1} risks the cosmic balance for a chance at glory. The potential for a monumental boost in performance is tantalizing, but the bat's whims could just as easily spell disaster, with a 50% chance of backfiring and diminishing the team's abilities.",
                entropy: 15, // Signifies a tilt towards chaos due to the gamble
                effects: [
                    {
                        'oneOf': [
                            {
                                'effect': {
                                    'skill': {
                                        target: { 'team': 1 },
                                        skill: { 'battingAccuracy': null }, // Placeholder for the positive outcome: a significant enhancement to the team's performance
                                        value: 30,
                                        permanent: false
                                    }
                                },
                                'weight': 1
                            },
                            {
                                'effect': {
                                    'trait': {
                                        target: { 'team': 1 },
                                        trait: { 'inspiring': null }, // Placeholder for the negative outcome: a detrimental effect that could hinder the team
                                        permanent: true
                                    }
                                },
                                'weight': 1
                            }
                        ]
                    }
                ],
                requirements: []
            },
            {
                name: "Respect the Cosmic Balance",
                description: "Heeding the starlight inscription's warning, {Team1} opts to leave the Celestial Bat untouched, respecting the cosmic equilibrium. This cautious approach safeguards them from potential calamity, preserving their current capabilities but foregoing the chance at a supernatural advantage.",
                entropy: -5, // Leaning towards order for choosing safety and balance over risk
                effects: [
                    // No direct effects, symbolizing the choice to maintain the status quo and avoid risk
                ],
                requirements: []
            }
        ],
        weight: {
            value: 1,
            affectedBy: undefined
        }
    },
    {
        id: 3,
        name: "The Great Prank War",
        description: "A prank war escalates between the {Team1} and the {Team2}.",
        options: [
            {
                name: "Escalate the Pranks",
                description: "The {Team1}, led by {Player1}, up the ante with an ingenious prank.",
                entropy: 15, // High chaos
                effects: [
                    {
                        'trait': {
                            target: { 'player': 4 },
                            trait: { 'inspiring': null }, // TODO - This is a placeholder
                            permanent: true
                        }
                    }
                ],
                requirements: []
            },
            {
                name: "Broker Peace",
                description: "Fed up with the disruptions, {Player2} from the {Team2} proposes a truce.",
                entropy: 20, // High order
                effects: [
                    {
                        'aura': {
                            matchGroup: 2,
                            match: 2,
                            aura: { 'doubleOrNothing': null } // TODO - This is a placeholder
                        }
                    },
                    { 'points': { points: 100 } }
                ],
                requirements: []
            }
        ],
        weight: {
            value: 1,
            affectedBy: undefined
        }
    }
];