import { Weapon } from "../ic-agent/declarations/main";

export let weapons: Weapon[] = [
    {
        id: "corrupted_branch",
        name: "Corrupted Branch",
        description: "A twisted branch that has been corrupted by dark magic.",
        baseStats: {
            accuracy: 0n,
            attacks: 1n,
            minDamage: 1n,
            maxDamage: 3n,
            criticalChance: 15n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            attack: 3n,
        }],
        unlockRequirement: []
    },
    {
        id: "iron_sword",
        name: "Iron Sword",
        description: "A sturdy iron sword, reliable in combat.",
        baseStats: {
            accuracy: 0n,
            attacks: 1n,
            minDamage: 2n,
            maxDamage: 4n,
            criticalChance: 10n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            attack: 1n,
        }],
        unlockRequirement: []
    },
    {
        id: "apprentice_wand",
        name: "Apprentice Wand",
        description: "A simple wand for novice mages.",
        baseStats: {
            accuracy: 5n,
            attacks: 1n,
            minDamage: 1n,
            maxDamage: 3n,
            criticalChance: 5n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            magic: 1n,
        }],
        unlockRequirement: []
    },
    {
        id: "iron_dagger",
        name: "Iron Dagger",
        description: "A quick and sharp iron dagger.",
        baseStats: {
            accuracy: 5n,
            attacks: 2n,
            minDamage: 1n,
            maxDamage: 2n,
            criticalChance: 15n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            speed: 1n,
        }],
        unlockRequirement: []
    },
    {
        id: "short_bow",
        name: "Short Bow",
        description: "A compact bow for quick shots.",
        baseStats: {
            accuracy: 10n,
            attacks: 1n,
            minDamage: 2n,
            maxDamage: 4n,
            criticalChance: 10n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            attack: 1n,
        }],
        unlockRequirement: []
    },
    {
        id: "oaken_staff",
        name: "Oaken Staff",
        description: "A staff carved from ancient oak, resonating with nature's power.",
        baseStats: {
            accuracy: 0n,
            attacks: 1n,
            minDamage: 1n,
            maxDamage: 3n,
            criticalChance: 5n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            magic: 1n,
        }],
        unlockRequirement: []
    },
    {
        id: "iron_mace",
        name: "Iron Mace",
        description: "A heavy iron mace for crushing blows.",
        baseStats: {
            accuracy: -5n,
            attacks: 1n,
            minDamage: 3n,
            maxDamage: 5n,
            criticalChance: 5n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            attack: 1n,
        }],
        unlockRequirement: []
    },
    {
        id: "basic_lute",
        name: "Basic Lute",
        description: "A simple lute for aspiring bards.",
        baseStats: {
            accuracy: 0n,
            attacks: 1n,
            minDamage: 1n,
            maxDamage: 2n,
            criticalChance: 5n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [],
        unlockRequirement: []
    },
    {
        id: "wooden_staff",
        name: "Wooden Staff",
        description: "A sturdy wooden staff for martial arts.",
        baseStats: {
            accuracy: 5n,
            attacks: 2n,
            minDamage: 1n,
            maxDamage: 2n,
            criticalChance: 10n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            speed: 1n,
        }],
        unlockRequirement: []
    },
    {
        id: "mechanic_wrench",
        name: "Mechanic's Wrench",
        description: "A versatile wrench for tinkering and bashing.",
        baseStats: {
            accuracy: 0n,
            attacks: 1n,
            minDamage: 2n,
            maxDamage: 3n,
            criticalChance: 10n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [],
        unlockRequirement: []
    },
    {
        id: "bone_staff",
        name: "Bone Staff",
        description: "A staff made from enchanted bones, radiating dark energy.",
        baseStats: {
            accuracy: 0n,
            attacks: 1n,
            minDamage: 1n,
            maxDamage: 3n,
            criticalChance: 5n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            magic: 1n,
        }],
        unlockRequirement: []
    },
    {
        id: "crude_daggers",
        name: "Crude Daggers",
        description: "Simple, roughly-made daggers favored by goblins for their quick attacks.",
        baseStats: {
            accuracy: 0n,
            attacks: 2n,
            minDamage: 1n,
            maxDamage: 2n,
            criticalChance: 10n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [{
            speed: 2n,
        }],
        unlockRequirement: []
    },
    {
        id: "shadow_bow",
        name: "Shadow Bow",
        description: "A sleek bow imbued with dark magic, favored by dark elves for its precision and power.",
        baseStats: {
            accuracy: 15n,
            attacks: 1n,
            minDamage: 2n,
            maxDamage: 5n,
            criticalChance: 15n,
            criticalMultiplier: 2n,
            statModifiers: []
        },
        requirements: [
            {
                attack: 2n,
            },
            {
                magic: 1n,
            }
        ],
        unlockRequirement: []
    },
];