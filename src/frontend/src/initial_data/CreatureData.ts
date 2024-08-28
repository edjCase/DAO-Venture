import { Creature } from "../ic-agent/declarations/main";

export const creatures: Creature[] = [
    {
        id: "corrupted_treant",
        name: "Corrupted Treant",
        description: "A once noble protector of the forest, now twisted by dark magic.",
        health: 10n,
        maxHealth: 10n,
        location: { zoneIds: ["enchanted_forest"] },
        attack: 3n,
        defense: 2n,
        speed: 1n,
        magic: 1n,
        weaponId: "corrupted_branch",
        kind: { elite: null }
    },
    {
        id: "goblins",
        name: "Goblin Horde",
        description: "A mischievous group of small, green-skinned creatures known for their cunning and trickery.",
        health: 8n,
        maxHealth: 8n,
        location: { zoneIds: ["enchanted_forest", "ancient_ruins"] },
        attack: 2n,
        defense: 1n,
        speed: 3n,
        magic: 0n,
        weaponId: "crude_daggers",
        kind: { normal: null }
    },
    {
        id: "dark_elves",
        name: "Dark Elf Squad",
        description: "A skilled group of subterranean elves known for their stealth and arcane abilities.",
        health: 12n,
        maxHealth: 12n,
        location: { zoneIds: ["ancient_ruins", "mystic_caves"] },
        attack: 3n,
        defense: 2n,
        speed: 2n,
        magic: 2n,
        weaponId: "shadow_bow",
        kind: { normal: null }
    },
];