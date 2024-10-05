import { Zone } from "../ic-agent/declarations/main";

export const zones: Zone[] = [
    {
        id: "enchanted_forest",
        name: "Enchanted Forest",
        description: "A mystical woodland teeming with magical creatures and ancient secrets.",
        difficulty: { easy: null },
        unlockRequirement: { none: null }
    },
    {
        id: "ancient_ruins",
        name: "Ancient Ruins",
        description: "Crumbling structures of a long-lost civilization, filled with forgotten knowledge and hidden dangers.",
        difficulty: { medium: null },
        unlockRequirement: { none: null }
    },
    // {
    //     id: "mystic_caves",
    //     name: "Mystic Caves",
    //     description: "A vast underground network of caverns, glowing with magical crystals and echoing with arcane energies.",
    //     difficulty: { medium: null },
    //     unlockRequirement: { none: null }
    // },
    {
        id: "scorching_desert",
        name: "Scorching Desert",
        description: "An unforgiving landscape of sand and heat, hiding oases of magic and ancient tombs.",
        difficulty: { hard: null },
        unlockRequirement: { none: null }
    },
    // {
    //     id: "treacherous_mountains",
    //     name: "Treacherous Mountains",
    //     description: "Sky-piercing peaks and deep valleys, home to hardy creatures and long-forgotten shrines.",
    //     difficulty: { hard: null },
    //     unlockRequirement: { none: null }
    // }
];