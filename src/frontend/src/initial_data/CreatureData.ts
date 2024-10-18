import { Creature } from "../ic-agent/declarations/main";

export const creatures: Creature[] = [
    {
        id: "corrupted_treant",
        name: "Corrupted Treant",
        description: "A once noble protector of the forest, now twisted by dark magic.",
        health: 10n,
        maxHealth: 10n,
        location: { zoneIds: ["enchanted_forest", "ancient_ruins", "scorching_desert"] },
        actionIds: ["entangle", "venom_strike", "wild_growth"],
        kind: { elite: null },
        unlockRequirement: { none: null }
    },
    {
        id: "goblin",
        name: "Goblin",
        description: "Mischievous small, green-skinned creatures known for their cunning and trickery.",
        health: 8n,
        maxHealth: 8n,
        location: { zoneIds: ["enchanted_forest", "ancient_ruins", "scorching_desert"] },
        actionIds: ["stab", "fury_swipes", "venom_strike"],
        kind: { normal: null },
        unlockRequirement: { none: null }
    },
    {
        id: "dark_elf",
        name: "Dark Elf",
        description: "A skilled subterranean elf known for their stealth and arcane abilities.",
        health: 12n,
        maxHealth: 12n,
        location: { zoneIds: ["enchanted_forest", "ancient_ruins", "scorching_desert"] },
        actionIds: ["shadow_bolt", "piercing_shot", "weaken"],
        kind: { normal: null },
        unlockRequirement: { none: null }
    },
    {
        id: "unicorn",
        name: "Unicorn",
        description: "A majestic creature with a single horn and a gentle spirit.",
        health: 20n,
        maxHealth: 20n,
        location: { zoneIds: ["enchanted_forest", "ancient_ruins", "scorching_desert"] },
        actionIds: ["stomp", "heal", "stab"],
        kind: { elite: null },
        unlockRequirement: { none: null }
    }
];