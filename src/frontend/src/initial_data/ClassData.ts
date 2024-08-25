import { Class } from "../ic-agent/declarations/main";

export const classes: Class[] = [
    {
        id: "warrior",
        name: "Warrior",
        description: "A warrior is a master of combat, using their strength and skill to defeat their foes.",
        modifiers: [
            { attack: 1n },
            { health: 10n },
            { trait: "strong" },
        ],
        unlockRequirement: [],
        weaponId: "iron_sword"
    },
    {
        id: "mage",
        name: "Mage",
        description: "A mage is a master of magic, using their knowledge of the arcane to cast powerful spells.",
        modifiers: [
            { magic: 1n },
            { trait: "alchemist" },
            { trait: "intelligent" },
        ],
        unlockRequirement: [],
        weaponId: "apprentice_wand"
    },
    {
        id: "rogue",
        name: "Rogue",
        description: "A rogue is a master of stealth, using their cunning and agility to outmaneuver their foes.",
        modifiers: [
            { speed: 1n },
            { gold: 10n },
            { trait: "agile" },
        ],
        unlockRequirement: [],
        weaponId: "iron_dagger"
    },
    {
        id: "archer",
        name: "Archer",
        description: "An archer is a master of ranged combat, using their precision and skill to strike from a distance.",
        modifiers: [
            { attack: 1n },
            { speed: 1n },
            { trait: "perceptive" },
        ],
        unlockRequirement: [],
        weaponId: "short_bow"
    },
    {
        id: "druid",
        name: "Druid",
        description: "A druid is a guardian of nature, wielding its power to protect and heal.",
        modifiers: [
            { magic: 1n },
            { health: 5n },
            { trait: "naturalist" },
        ],
        unlockRequirement: [],
        weaponId: "oaken_staff"
    },
    {
        id: "paladin",
        name: "Paladin",
        description: "A paladin is a holy warrior, combining martial prowess with divine magic.",
        modifiers: [
            { attack: 1n },
            { defense: 1n },
            { trait: "holy" },
        ],
        unlockRequirement: [],
        weaponId: "iron_mace"
    },
    {
        id: "bard",
        name: "Bard",
        description: "A bard is a jack-of-all-trades, using music and charm to inspire allies and confound enemies.",
        modifiers: [
            { magic: 1n },
            { speed: 1n },
            { trait: "charismatic" },
        ],
        unlockRequirement: [],
        weaponId: "basic_lute"
    },
    {
        id: "monk",
        name: "Monk",
        description: "A monk is a martial artist, harnessing inner energy to perform incredible feats.",
        modifiers: [
            { speed: 2n },
            { trait: "tough" },
        ],
        unlockRequirement: [],
        weaponId: "wooden_staff"
    },
    {
        id: "artificer",
        name: "Artificer",
        description: "An artificer is an inventor, combining magic with technology to create powerful gadgets.",
        modifiers: [
            { defense: 1n },
            { attack: 1n },
            { trait: "crafty" },
        ],
        unlockRequirement: [],
        weaponId: "mechanic_wrench"
    },
    {
        id: "necromancer",
        name: "Necromancer",
        description: "A necromancer is a master of death magic, commanding undead and draining life force.",
        modifiers: [
            { magic: 2n },
            { health: -5n },
            { trait: "cursed" },
        ],
        unlockRequirement: [],
        weaponId: "bone_staff"
    },
];