import { Race } from "../ic-agent/declarations/main";

export const races: Race[] = [
    {
        id: "human",
        name: "Human",
        description: "Humans are versatile and adaptable.",
        startingActionIds: ["slash", "shield"],
        unlockRequirement: [],
        startingItemIds: ["adaptable_charm"]
    },
    {
        id: "elf",
        name: "Elf",
        description: "Elves are graceful and attuned to nature.",
        startingActionIds: ["piercing_shot", "entangle"],
        unlockRequirement: [],
        startingItemIds: ["nature_pendant"]
    },
    {
        id: "dwarf",
        name: "Dwarf",
        description: "Dwarves are sturdy and resilient.",
        startingActionIds: ["defensive_stance", "double_slash"],
        unlockRequirement: [],
        startingItemIds: ["endurance_belt"]
    },
    {
        id: "halfling",
        name: "Halfling",
        description: "Halflings are small and nimble.",
        startingActionIds: ["stab", "rapid_shot"],
        unlockRequirement: [],
        startingItemIds: ["stealth_cloak"]
    },
    {
        id: "faerie",
        name: "Faerie",
        description: "Faeries are mysterious and enchanting.",
        startingActionIds: ["arcane_missiles", "regenerate"],
        unlockRequirement: [],
        startingItemIds: ["charm_amulet"]
    }
];