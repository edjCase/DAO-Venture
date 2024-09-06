import { Action } from "../ic-agent/declarations/main";

export const actions: Action[] = [
    {
        id: "stab",
        name: "Stab",
        description: "A quick, precise attack",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 2n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "slash",
        name: "Slash",
        description: "A powerful slashing attack",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 4n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "fireball",
        name: "Fireball",
        description: "Conjure a ball of fire that explodes and burns",
        target: {
            scope: { enemy: null },
            selection: { all: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 3n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { damage: { timing: { periodic: { phase: { start: null }, remainingTurns: 2n } }, min: 1n, max: 1n } }
            }
        ]
    },
    {
        id: "heal",
        name: "Heal",
        description: "Restore health to an ally",
        target: {
            scope: { ally: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { heal: { min: 3n, max: 5n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "shield",
        name: "Shield",
        description: "Protect yourself or an ally",
        target: {
            scope: { ally: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { block: { min: 3n, max: 5n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "poison_dart",
        name: "Poison Dart",
        description: "A small, poisoned projectile that deals damage over time",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 2n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { damage: { timing: { periodic: { phase: { start: null }, remainingTurns: 3n } }, min: 2n, max: 2n } }
            }
        ]
    },
    {
        id: "whirlwind",
        name: "Whirlwind",
        description: "Spin and hit all enemies",
        target: {
            scope: { enemy: null },
            selection: { all: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 3n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "thorns_aura",
        name: "Thorns Aura",
        description: "Surround an ally with thorns, damaging attackers",
        target: {
            scope: { ally: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { retaliating: { flat: 1n } }, duration: [3n] } }
            }
        ]
    },
    {
        id: "life_drain",
        name: "Life Drain",
        description: "Drain health from an enemy to heal yourself",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 4n, timing: { immediate: null } } }
            },
            {
                target: { self: null },
                kind: { heal: { min: 1n, max: 2n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "smite",
        name: "Smite",
        description: "A powerful holy attack that damages and weakens",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 3n, max: 5n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { weak: null }, duration: [2n] } }
            }
        ]
    },
    {
        id: "entangle",
        name: "Entangle",
        description: "Restrict an enemy's movement, making them vulnerable",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { vulnerable: null }, duration: [2n] } }
            }
        ]
    },
    {
        id: "fury_swipes",
        name: "Fury Swipes",
        description: "A flurry of three quick attacks",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 1n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 1n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 1n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "frost_bolt",
        name: "Frost Bolt",
        description: "Launch a freezing projectile that stuns the target",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 3n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { stunned: null }, duration: [1n] } }
            }
        ]
    },
    {
        id: "earthquake",
        name: "Earthquake",
        description: "Shake the ground, damaging all characters",
        target: {
            scope: { any: null },
            selection: { all: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 4n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "rapid_shot",
        name: "Rapid Shot",
        description: "Fire two arrows at random enemies",
        target: {
            scope: { enemy: null },
            selection: { random: { count: 2n } }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 3n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "defensive_stance",
        name: "Defensive Stance",
        description: "Assume a defensive position, gaining a shield and retaliating against attacks",
        target: {
            scope: { ally: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { block: { min: 3n, max: 5n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { retaliating: { flat: 1n } }, duration: [2n] } }
            }
        ]
    },
    {
        id: "venom_strike",
        name: "Venom Strike",
        description: "A poisonous attack that deals damage over time",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 2n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { damage: { timing: { periodic: { phase: { start: null }, remainingTurns: 3n } }, min: 1n, max: 1n } }
            }
        ]
    },
    {
        id: "thunder_strike",
        name: "Thunder Strike",
        description: "A powerful lightning attack that stuns",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 3n, max: 5n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { stunned: null }, duration: [1n] } }
            }
        ]
    },
    {
        id: "regenerate",
        name: "Regenerate",
        description: "Grant an ally healing over time",
        target: {
            scope: { ally: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { heal: { timing: { periodic: { phase: { start: null }, remainingTurns: 3n } }, min: 2n, max: 2n } }
            }
        ]
    },
    {
        id: "double_slash",
        name: "Double Slash",
        description: "Two quick slashes at a single target",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 3n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 3n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "war_cry",
        name: "War Cry",
        description: "A rallying shout that weakens all enemies",
        target: {
            scope: { enemy: null },
            selection: { all: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { weak: null }, duration: [2n] } }
            }
        ]
    },
    {
        id: "piercing_shot",
        name: "Piercing Shot",
        description: "An armor-piercing attack that makes the target vulnerable",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 4n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { vulnerable: null }, duration: [2n] } }
            }
        ]
    },
    {
        id: "wild_growth",
        name: "Wild Growth",
        description: "Summon vines to protect an ally, granting a shield",
        target: {
            scope: { ally: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { block: { min: 4n, max: 6n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "weaken",
        name: "Weaken",
        description: "Sap the strength from an enemy, reducing their damage",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { weak: null }, duration: [2n] } }
            }
        ]
    },
    {
        id: "arcane_missiles",
        name: "Arcane Missiles",
        description: "Launch three magical projectiles at random enemies",
        target: {
            scope: { enemy: null },
            selection: { random: { count: 3n } }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 2n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "berserk",
        name: "Berserk",
        description: "Enter a frenzied state, gaining retaliation but becoming vulnerable",
        target: {
            scope: { ally: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { retaliating: { flat: 2n } }, duration: [3n] } }
            },
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { vulnerable: null }, duration: [3n] } }
            }
        ]
    },
    {
        id: "shadow_bolt",
        name: "Shadow Bolt",
        description: "A dark projectile that damages and weakens",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 4n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { weak: null }, duration: [2n] } }
            }
        ]
    },
    {
        id: "chain_lightning",
        name: "Chain Lightning",
        description: "A bolt of lightning that jumps between multiple enemies",
        target: {
            scope: { enemy: null },
            selection: { random: { count: 3n } }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 3n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "fortify",
        name: "Fortify",
        description: "Strengthen an ally's defenses, granting a shield and damage reduction",
        target: {
            scope: { ally: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { block: { min: 3n, max: 5n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { addStatusEffect: { kind: { retaliating: { flat: 1n } }, duration: [2n] } }
            }
        ]
    },
    {
        id: "precision_strike",
        name: "Precision Strike",
        description: "A carefully aimed attack that always hits for maximum damage",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 4n, max: 4n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "vampiric_touch",
        name: "Vampiric Touch",
        description: "Drain life from an enemy, healing yourself for half the damage dealt",
        target: {
            scope: { enemy: null },
            selection: { chosen: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 2n, max: 4n, timing: { immediate: null } } }
            },
            {
                target: { self: null },
                kind: { heal: { min: 1n, max: 2n, timing: { immediate: null } } }
            }
        ]
    },
    {
        id: "natures_wrath",
        name: "Nature's Wrath",
        description: "Summon nature's fury to damage all enemies and poison them",
        target: {
            scope: { enemy: null },
            selection: { all: null }
        },
        effects: [
            {
                target: { targets: null },
                kind: { damage: { min: 1n, max: 2n, timing: { immediate: null } } }
            },
            {
                target: { targets: null },
                kind: { damage: { timing: { periodic: { phase: { start: null }, remainingTurns: 2n } }, min: 1n, max: 2n } }
            }
        ]
    }
];