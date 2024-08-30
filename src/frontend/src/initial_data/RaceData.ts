import { Race } from "../ic-agent/declarations/main";


export const races: Race[] = [
    {
        id: "human",
        name: "Human",
        description: "Humans are versatile and adaptable.",
        modifiers: [
            { attack: 1n },
            { defense: 1n },
            { trait: "clever" },
        ],
        unlockRequirement: []
    },
    {
        id: "elf",
        name: "Elf",
        description: "Elves are graceful and attuned to nature.",
        modifiers: [
            { magic: 1n },
            { speed: 1n },
            { trait: "naturalist" },
        ],
        unlockRequirement: []
    },
    {
        id: "dwarf",
        name: "Dwarf",
        description: "Dwarves are sturdy and resilient.",
        modifiers: [
            { defense: 2n },
            { health: 10n },
            { trait: "tough" },
        ],
        unlockRequirement: []
    },
    {
        id: "halfling",
        name: "Halfling",
        description: "Halflings are small and nimble.",
        modifiers: [
            { speed: 2n },
            { defense: 1n },
            { trait: "stealthy" },
        ],
        unlockRequirement: []
    },
    {
        id: "faerie",
        name: "Faerie",
        description: "Faeries are mysterious and enchanting.",
        modifiers: [
            { magic: 2n },
            { speed: 1n },
            { trait: "charismatic" },
        ],
        unlockRequirement: []
    },
];