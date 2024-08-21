

export const races  = [
    {
        id: "human",
        name: "Human",
        description: "Humans are versatile and adaptable.",
        modifiers: [
            { attack: 1n },
            { defense: 1n },
            { trait: "clever" },
        ],
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
    },
];