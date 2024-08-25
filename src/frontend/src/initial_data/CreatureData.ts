import { Creature } from "../ic-agent/declarations/main";


export const creatures: Creature[] = [
    {
        id: "corrupted_treant",
        name: "Corrupted Treant",
        description: "A once noble protector of the forest, now twisted by dark magic.",
        health: 10n,
        location: { zoneIds: ["enchanted_forest"] },
        stats: {
            attack: 3n,
            defense: 2n,
            speed: 1n,
            magic: 1n
        },
        weapon
    },
];