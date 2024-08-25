import { Weapon } from "../ic-agent/declarations/main";

export let weapons: Weapon[] = [
    {
        id: "corrupted_branch",
        name: "Corrupted Branch",
        description: "A twisted branch that has been corrupted by dark magic.",
        baseStats: {
            accuracy: 0n,
            damage: {
                attacks: 1n,
                min: 1n,
                max: 3n
            },
            criticalChance: 15n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            attack: 3n,
        }]
    },
    {
        id: "iron_sword",
        name: "Iron Sword",
        description: "A sturdy iron sword, reliable in combat.",
        baseStats: {
            accuracy: 0n,
            damage: {
                attacks: 1n,
                min: 2n,
                max: 4n
            },
            criticalChance: 10n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            attack: 1n,
        }]
    },
    {
        id: "apprentice_wand",
        name: "Apprentice Wand",
        description: "A simple wand for novice mages.",
        baseStats: {
            accuracy: 5n,
            damage: {
                attacks: 1n,
                min: 1n,
                max: 3n
            },
            criticalChance: 5n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            magic: 1n,
        }]
    },
    {
        id: "iron_dagger",
        name: "Iron Dagger",
        description: "A quick and sharp iron dagger.",
        baseStats: {
            accuracy: 5n,
            damage: {
                attacks: 2n,
                min: 1n,
                max: 2n
            },
            criticalChance: 15n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            speed: 1n,
        }]
    },
    {
        id: "short_bow",
        name: "Short Bow",
        description: "A compact bow for quick shots.",
        baseStats: {
            accuracy: 10n,
            damage: {
                attacks: 1n,
                min: 2n,
                max: 4n
            },
            criticalChance: 10n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            attack: 1n,
        }]
    },
    {
        id: "oaken_staff",
        name: "Oaken Staff",
        description: "A staff carved from ancient oak, resonating with nature's power.",
        baseStats: {
            accuracy: 0n,
            damage: {
                attacks: 1n,
                min: 1n,
                max: 3n
            },
            criticalChance: 5n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            magic: 1n,
        }]
    },
    {
        id: "iron_mace",
        name: "Iron Mace",
        description: "A heavy iron mace for crushing blows.",
        baseStats: {
            accuracy: -5n,
            damage: {
                attacks: 1n,
                min: 3n,
                max: 5n
            },
            criticalChance: 5n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            attack: 1n,
        }]
    },
    {
        id: "basic_lute",
        name: "Basic Lute",
        description: "A simple lute for aspiring bards.",
        baseStats: {
            accuracy: 0n,
            damage: {
                attacks: 1n,
                min: 1n,
                max: 2n
            },
            criticalChance: 5n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: []
    },
    {
        id: "wooden_staff",
        name: "Wooden Staff",
        description: "A sturdy wooden staff for martial arts.",
        baseStats: {
            accuracy: 5n,
            damage: {
                attacks: 2n,
                min: 1n,
                max: 2n
            },
            criticalChance: 10n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            speed: 1n,
        }]
    },
    {
        id: "mechanic_wrench",
        name: "Mechanic's Wrench",
        description: "A versatile wrench for tinkering and bashing.",
        baseStats: {
            accuracy: 0n,
            damage: {
                attacks: 1n,
                min: 2n,
                max: 3n
            },
            criticalChance: 10n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: []
    },
    {
        id: "bone_staff",
        name: "Bone Staff",
        description: "A staff made from enchanted bones, radiating dark energy.",
        baseStats: {
            accuracy: 0n,
            damage: {
                attacks: 1n,
                min: 1n,
                max: 3n
            },
            criticalChance: 5n,
            criticalMultiplier: 2n,
            boosts: []
        },
        requirements: [{
            magic: 1n,
        }]
    },
];