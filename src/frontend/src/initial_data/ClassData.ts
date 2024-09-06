import { Class } from "../ic-agent/declarations/main";

export const classes: Class[] = [
    {
        id: "warrior",
        name: "Warrior",
        description: "A warrior is a master of combat, using their strength and skill to defeat their foes.",
        actionIds: ["slash", "defensive_stance"],
        weaponId: "iron_sword",
        unlockRequirement: [],
        startingTraitIds: ["strong"]
    },
    {
        id: "mage",
        name: "Mage",
        description: "A mage is a master of magic, using their knowledge of the arcane to cast powerful spells.",
        actionIds: ["fireball", "frost_bolt"],
        weaponId: "apprentice_wand",
        unlockRequirement: [],
        startingTraitIds: ["intelligent"]
    },
    {
        id: "rogue",
        name: "Rogue",
        description: "A rogue is a master of stealth, using their cunning and agility to outmaneuver their foes.",
        actionIds: ["stab", "venom_strike"],
        weaponId: "iron_dagger",
        unlockRequirement: [],
        startingTraitIds: ["agile"]
    },
    {
        id: "archer",
        name: "Archer",
        description: "An archer is a master of ranged combat, using their precision and skill to strike from a distance.",
        actionIds: ["piercing_shot", "rapid_shot"],
        weaponId: "short_bow",
        unlockRequirement: [],
        startingTraitIds: ["perceptive"]
    },
    {
        id: "druid",
        name: "Druid",
        description: "A druid is a guardian of nature, wielding its power to protect and heal.",
        actionIds: ["heal", "entangle"],
        weaponId: "oaken_staff",
        unlockRequirement: [],
        startingTraitIds: ["naturalist"]
    },
    {
        id: "paladin",
        name: "Paladin",
        description: "A paladin is a holy warrior, combining martial prowess with divine magic.",
        actionIds: ["smite", "shield"],
        weaponId: "iron_mace",
        unlockRequirement: [],
        startingTraitIds: ["holy"]
    },
    {
        id: "bard",
        name: "Bard",
        description: "A bard is a jack-of-all-trades, using music and charm to inspire allies and confound enemies.",
        actionIds: ["war_cry", "regenerate"],
        weaponId: "basic_lute",
        unlockRequirement: [],
        startingTraitIds: ["charismatic"]
    },
    {
        id: "monk",
        name: "Monk",
        description: "A monk is a martial artist, harnessing inner energy to perform incredible feats.",
        actionIds: ["fury_swipes", "wild_growth"],
        weaponId: "wooden_staff",
        unlockRequirement: [],
        startingTraitIds: ["tough"]
    },
    {
        id: "artificer",
        name: "Artificer",
        description: "An artificer is an inventor, combining magic with technology to create powerful gadgets.",
        actionIds: ["thunder_strike", "fortify"],
        weaponId: "mechanic_wrench",
        unlockRequirement: [],
        startingTraitIds: ["crafty"]
    },
    {
        id: "necromancer",
        name: "Necromancer",
        description: "A necromancer is a master of death magic, commanding undead and draining life force.",
        actionIds: ["life_drain", "shadow_bolt"],
        weaponId: "bone_staff",
        unlockRequirement: [],
        startingTraitIds: ["cursed"]
    },
];