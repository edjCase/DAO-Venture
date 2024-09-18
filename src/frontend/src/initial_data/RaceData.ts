import { Race } from "../ic-agent/declarations/main";

export const races: Race[] = [
    {
        id: "human",
        name: "Human",
        description: "Humans are versatile and adaptable.",
        startingSkillActionIds: ["slash", "shield"],
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "elf",
        name: "Elf",
        description: "Elves are graceful and attuned to nature.",
        startingSkillActionIds: ["piercing_shot", "entangle"],
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "dwarf",
        name: "Dwarf",
        description: "Dwarves are sturdy and resilient.",
        startingSkillActionIds: ["defensive_stance", "double_slash"],
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "halfling",
        name: "Halfling",
        description: "Halflings are small and nimble.",
        startingSkillActionIds: ["stab", "rapid_shot"],
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "faerie",
        name: "Faerie",
        description: "Faeries are mysterious and enchanting.",
        startingSkillActionIds: ["arcane_missiles", "regenerate"],
        unlockRequirement: [],
        startingItemIds: []
    }
];