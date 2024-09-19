import { Class } from "../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../utils/PixelUtil";

export const classes: Class[] = [
    {
        id: "warrior",
        name: "Warrior",
        description: "A warrior is a master of combat, using their strength and skill to defeat their foes.",
        startingSkillActionIds: ["slash", "defensive_stance"],
        weaponId: "iron_sword",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["power_gauntlets"]
    },
    {
        id: "mage",
        name: "Mage",
        description: "A mage is a master of magic, using their knowledge of the arcane to cast powerful spells.",
        startingSkillActionIds: ["fireball", "frost_bolt"],
        weaponId: "apprentice_wand",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["arcane_tome"]
    },
    {
        id: "rogue",
        name: "Rogue",
        description: "A rogue is a master of stealth, using their cunning and agility to outmaneuver their foes.",
        startingSkillActionIds: ["stab", "venom_strike"],
        weaponId: "iron_dagger",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["boots_of_sneaking"]
    },
    {
        id: "archer",
        name: "Archer",
        description: "An archer is a master of ranged combat, using their precision and skill to strike from a distance.",
        startingSkillActionIds: ["piercing_shot", "rapid_shot"],
        weaponId: "short_bow",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["eagle_eye_amulet"]
    },
    {
        id: "druid",
        name: "Druid",
        description: "A druid is a guardian of nature, wielding its power to protect and heal.",
        startingSkillActionIds: ["heal", "entangle"],
        weaponId: "oaken_staff",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["nature_pendant"]
    },
    {
        id: "paladin",
        name: "Paladin",
        description: "A paladin is a holy warrior, combining martial prowess with divine magic.",
        startingSkillActionIds: ["smite", "shield"],
        weaponId: "iron_mace",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["divine_emblem"]
    },
    {
        id: "bard",
        name: "Bard",
        description: "A bard is a jack-of-all-trades, using music and charm to inspire allies and confound enemies.",
        startingSkillActionIds: ["war_cry", "regenerate"],
        weaponId: "basic_lute",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["harmonic_charm"]
    },
    {
        id: "monk",
        name: "Monk",
        description: "A monk is a martial artist, harnessing inner energy to perform incredible feats.",
        startingSkillActionIds: ["fury_swipes", "wild_growth"],
        weaponId: "wooden_staff",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["endurance_belt"]
    },
    {
        id: "artificer",
        name: "Artificer",
        description: "An artificer is an inventor, combining magic with technology to create powerful gadgets.",
        startingSkillActionIds: ["thunder_strike", "fortify"],
        weaponId: "mechanic_wrench",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["artificer_toolbox"]
    },
    {
        id: "necromancer",
        name: "Necromancer",
        description: "A necromancer is a master of death magic, commanding undead and draining life force.",
        startingSkillActionIds: ["life_drain", "shadow_bolt"],
        weaponId: "bone_staff",
        image: decodeBase64ToImage("Dz1cjztcjCpVgCoqVTtfjDxeizdZkE6PuU6PujxejD1fjEuWtE+PuU+Puk6QvIsG/wEAAQEBAgT/AQMBAQEAFv8BBAEFAQYE/wEGAQUBBBL/AQcDCAIFAQkBCgL/AQoBCQIFAwgBBwz/AQsBBwEMAw0EBQIEBAUDDQEMAQcBCwr/AQ4FDQoFBQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4JDQIFCQ0BDgr/AQ4DDQEFBQ0CBQUNAQUDDQEOBf8="),
        unlockRequirement: [],
        startingItemIds: ["dark_essence_vial"]
    },
];