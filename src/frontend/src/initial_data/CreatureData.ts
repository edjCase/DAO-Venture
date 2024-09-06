import { Creature } from "../ic-agent/declarations/main";

export const creatures: Creature[] = [
    {
        id: "corrupted_treant",
        name: "Corrupted Treant",
        description: "A once noble protector of the forest, now twisted by dark magic.",
        health: 10n,
        maxHealth: 10n,
        location: { zoneIds: ["enchanted_forest"] },
        actionIds: ["entangle", "venom_strike", "wild_growth"],
        weaponId: "corrupted_branch",
        kind: { elite: null },
        unlockRequirement: []
    },
    {
        id: "goblin",
        name: "Goblin",
        description: "Mischievous small, green-skinned creatures known for their cunning and trickery.",
        health: 8n,
        maxHealth: 8n,
        location: { zoneIds: ["enchanted_forest", "ancient_ruins"] },
        actionIds: ["stab", "fury_swipes", "venom_strike"],
        weaponId: "crude_daggers",
        kind: { normal: null },
        unlockRequirement: []
    },
    {
        id: "dark_elf",
        name: "Dark Elf",
        description: "A skilled subterranean elf known for their stealth and arcane abilities.",
        health: 12n,
        maxHealth: 12n,
        location: { zoneIds: ["ancient_ruins", "mystic_caves"] },
        actionIds: ["shadow_bolt", "piercing_shot", "weaken"],
        weaponId: "shadow_bow",
        kind: { normal: null },
        unlockRequirement: []
    },
];