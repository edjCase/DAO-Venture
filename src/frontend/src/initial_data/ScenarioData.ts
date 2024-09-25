import { ScenarioMetaData } from "../ic-agent/declarations/main";

export const scenarios: ScenarioMetaData[] = [
  {
    id: "corrupted_treant",
    name: "Corrupted Treant",
    description: "A massive, twisted tree creature blocks your path. Dark energy pulses through its bark, its once-peaceful nature warped by an unknown force.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "combat": null },
    imageId: "corrupted_treant",
    paths: [
      {
        id: "start",
        description: "The corrupted treant looms before you, its branches creaking ominously.",
        kind: {
          choice: {
            choices: [
              {
                id: "attack",
                description: "Engage the corrupted treant in combat.",
                requirement: [],
                effects: [],
                nextPath: { single: "attack_treant" },
              },
              {
                id: "purify",
                description: "Attempt to cleanse the corruption using magic.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.25, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your efforts succeed in cleansing the corruption from the treant.",
                      effects: [],
                      pathId: ["purification_success"]
                    },
                    {
                      weight: { value: 0.75, kind: { raw: null } },
                      description: "Your attempt fails, and the corruption lashes out at you, dealing damage.",
                      effects: [
                        {
                          damage: { raw: 10n }
                        }
                      ],
                      pathId: ["start"]
                    },
                  ]
                },
              },
              {
                id: "consume_item",
                description: "Use a nature pendant to purify the treant.",
                requirement: [{ itemWithTags: ["cleansing"] }],
                effects: [{
                  removeItemWithTags: ["cleansing"]
                }],
                nextPath: { single: "purification_success" },
              },
              {
                id: "retreat",
                description: "Retreat from the treant, sacrificing resources for safety.",
                requirement: [],
                effects: [{
                  removeGold: {
                    raw: 10n
                  }
                }],
                nextPath: { none: null },
              },
            ],
          }
        }
      },
      {
        id: "purification_success",
        description: "The treant thanks you for your help and disappears, leaving behind a glowing artifact.",
        kind: {
          reward: {
            kind: { random: null },
            nextPath: { none: null }
          }
        },
      },
      {
        id: "attack_treant",
        description: "You attack the treant.",
        kind: {
          combat: {
            creatures: [{ id: "corrupted_treant" }],
            nextPath: { none: null }
          }
        },
      },
    ],
    unlockRequirement: []
  },
  {
    "id": "dark_elf_ambush",
    "name": "Dark Elf Ambush",
    "description": "A group of dark elves emerges from the shadows, weapons drawn. Their eyes gleam with malicious intent.",
    "location": {
      "zoneIds": ["enchanted_forest"]
    },
    "category": { "combat": null },
    "imageId": "dark_elf_ambush",
    "paths": [
      {
        "id": "start",
        "description": "The dark elves have you surrounded. You must act quickly.",
        "kind": {
          "choice": {
            "choices": [
              {
                "id": "fight",
                "description": "Stand your ground and engage the dark elves in combat.",
                "requirement": [],
                "effects": [],
                "nextPath": { "single": "combat" }
              },
              {
                "id": "negotiate",
                "description": "Attempt to parley with the dark elves, offering something in exchange for safe passage.",
                "requirement": [],
                "effects": [],
                "nextPath": {
                  "multi": [
                    {
                      "weight": { "value": 0.3, "kind": { "attributeScaled": { "charisma": null } } },
                      "description": "Your silver tongue convinces the dark elves to let you pass.",
                      "effects": [],
                      "pathId": ["negotiate_success"]
                    },
                    {
                      "weight": { "value": 0.7, "kind": { "raw": null } },
                      "description": "The dark elves are not swayed by your words and attack!",
                      "effects": [],
                      "pathId": ["combat"]
                    }
                  ]
                }
              },
              {
                "id": "stealth",
                "description": "Use stealth to sneak past the dark elves without being detected.",
                "requirement": [{ itemWithTags: ["stealth"] }],
                "effects": [],
                "nextPath": {
                  "multi": [
                    {
                      "weight": { "value": 0.4, "kind": { "attributeScaled": { "dexterity": null } } },
                      "description": "You successfully sneak past the dark elves without being detected.",
                      "effects": [],
                      "pathId": ["stealth_success"]
                    },
                    {
                      "weight": { "value": 0.6, "kind": { "raw": null } },
                      "description": "Despite your efforts, the dark elves spot you and attack!",
                      "effects": [],
                      "pathId": ["combat"]
                    }
                  ]
                }
              },
              {
                "id": "retreat",
                "description": "Try to escape from the ambush, potentially leaving behind some resources.",
                "requirement": [],
                "effects": [
                  {
                    "removeGold": {
                      "random": [5n, 15n]
                    }
                  }
                ],
                "nextPath": {
                  "multi": [
                    {
                      "weight": { "value": 0.5, "kind": { "raw": null } },
                      "description": "You manage to escape, but at a cost.",
                      "effects": [],
                      "pathId": ["retreat_success"]
                    },
                    {
                      "weight": { "value": 0.5, "kind": { "raw": null } },
                      "description": "Your retreat fails, and the dark elves catch up to you!",
                      "effects": [
                        {
                          "damage": { "raw": 5n }
                        }
                      ],
                      "pathId": ["combat"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        "id": "combat",
        "description": "The dark elves attack!",
        "kind": {
          "combat": {
            "creatures": [{ "id": "dark_elf" }, { "id": "dark_elf" }],
            "nextPath": { "single": "post_combat" }
          }
        }
      },
      {
        "id": "negotiate_success",
        "description": "The dark elves accept your offer and let you pass.",
        "kind": {
          "reward": {
            "kind": { "random": null },
            "nextPath": { "none": null }
          }
        }
      },
      {
        "id": "stealth_success",
        "description": "You successfully sneak past the dark elves, finding a hidden cache they were guarding.",
        "kind": {
          "reward": {
            "kind": { "random": null },
            "nextPath": { "none": null }
          }
        }
      },
      {
        "id": "retreat_success",
        "description": "You successfully escape the dark elf ambush, but at a cost.",
        "kind": {
          "reward": {
            "kind": { "random": null },
            "nextPath": { "none": null }
          }
        }
      },
      {
        "id": "post_combat",
        "description": "With the dark elves defeated, you search their belongings.",
        "kind": {
          "reward": {
            "kind": { "random": null },
            "nextPath": { "none": null }
          }
        }
      }
    ],
    "unlockRequirement": []
  },
  {
    id: "druidic_sanctuary",
    name: "Druidic Sanctuary",
    description: "You enter a serene grove where druids commune with nature. The trees seem to be whispering gossip.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    imageId: "druidic_sanctuary",
    paths: [
      {
        id: "start",
        description: "The air is thick with magic and the scent of herbs. What do you do?",
        kind: {
          choice: {
            choices: [
              {
                id: "seek_healing",
                description: "Seek healing from the druids. Side effects may include turning into a tree.",
                requirement: [{ gold: 20n }],
                effects: [{ removeGold: { raw: 20n } }],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                      description: "The druids' magic flows through you, mending your wounds.",
                      effects: [{ heal: { raw: 15n } }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The healing magic fizzles, leaving you with a mild case of leaf-itis.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "commune_with_nature",
                description: "Commune with nature. Hope you speak fluent squirrel.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { wisdom: null } } },
                      description: "You successfully commune with nature. A squirrel imparts ancient wisdom, and hands you a nut... er, herb.",
                      effects: [{ addItem: "herbs" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "Your attempt at communing results in a lengthy conversation with a sassy fern. You're not sure, but you think it just insulted your haircut.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "leave",
                description: "Leave the sanctuary. The pollen was getting to you anyway.",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "dwarven_weaponsmith",
    name: "Dwarven Weaponsmith",
    description: "You encounter a surly dwarven weaponsmith, his beard singed and eyebrows smoking. He offers weapon upgrades at prices that could make a dragon weep.",
    location: {
      // zoneIds: ["mystic_caves"], TODO
      common: null
    },
    category: { "store": null },
    imageId: "dwarven_weaponsmith",
    paths: [
      {
        id: "start",
        description: "The dwarf eyes you suspiciously, his gaze alternating between your weapon and your coin purse. What do you do?",
        kind: {
          choice: {
            choices: [
              {
                id: "upgrade_weapon",
                description: "Request a weapon upgrade. Hope you're not too attached to your gold.",
                requirement: [{ gold: 30n }],
                effects: [{ removeGold: { raw: 30n } }],
                nextPath: {
                  single: "weapon_reward"
                }
              },
              {
                id: "haggle",
                description: "Attempt to haggle. The dwarf's eye twitches dangerously.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { charisma: null } } },
                      description: "The dwarf grumbles but offers a discount. You're pretty sure you heard him mutter 'smooth-talker' under his breath.",
                      effects: [],
                      pathId: ["discounted_upgrade"]
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "The dwarf's face turns as red as his forge. Haggling failed spectacularly.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "impress_smith",
                description: "Flex your muscles and offer to help around the forge.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { strength: null } } },
                      description: "The weaponsmith's eyes light up. You spend an hour moving heavy anvils before he offers a discounted upgrade.",
                      effects: [],
                      pathId: ["discounted_upgrade"]
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The dwarf looks unimpressed. 'Nice try, but I've seen stronger beards.'",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "leave",
                description: "Leave the shop. You didn't need two kidneys anyway.",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      },
      {
        id: "discounted_upgrade",
        description: "The dwarf offers a discounted upgrade. It's still expensive, but at least you'll have enough left for a single ale.",
        kind: {
          choice: {
            choices: [
              {
                id: "accept_discount",
                description: "Accept the discounted upgrade.",
                requirement: [{ gold: 20n }],
                effects: [{ removeGold: { raw: 20n } }],
                nextPath: { single: "weapon_reward" }
              },
              {
                id: "refuse_discount",
                description: "Refuse the discount. The ale was more tempting anyway.",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      },
      {
        id: "weapon_reward",
        description: "The dwarf hands you your upgraded weapon, muttering something about 'finest craftsmanship' and 'ungrateful adventurers'.",
        kind: {
          reward: {
            kind: { random: null },
            nextPath: { none: null }
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "enchanted_grove",
    name: "Enchanted Grove",
    description: "You enter a serene grove where the trees whisper secrets and the flowers giggle. It's either very magical or you've eaten some questionable mushrooms.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    imageId: "enchanted_grove",
    paths: [
      {
        id: "start",
        description: "The air shimmer with magic, and you swear a squirrel just winked at you. What do you do?",
        kind: {
          choice: {
            choices: [
              {
                id: "meditate",
                description: "Meditate to increase your magical attunement. Try not to think about acorns.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { wisdom: null } } },
                      description: "You achieve a state of perfect harmony with the grove. You can hear colors and see sounds.",
                      effects: [{ heal: { raw: 10n } }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "Your meditation is interrupted by a chatty bluejay. You learn a lot about forest gossip, but not much magic.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "harvest",
                description: "Harvest rare herbs. The plants look eager... suspiciously eager.",
                requirement: [],
                effects: [{ damage: { raw: 2n } }],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                      description: "You successfully harvest rare herbs, though a fern slaps your hand for picking its cousin.",
                      effects: [{ addItem: "herbs" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "You grab what you think are herbs. Turns out it's just fancy crabgrass with a good publicist.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "commune",
                description: "Commune with nature spirits. Hope you're fluent in squirrel.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { wisdom: null } } },
                      description: "The spirits grant you mystic knowledge. Unfortunately, it's mostly tree puns.",
                      effects: [{ addItemWithTags: ["crystal"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "You have a long conversation with what you thought was a spirit. Turns out it was just a very philosophical mushroom.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "leave",
                description: "Leave the grove. The talking trees are getting a bit too judgy about your life choices.",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "faerie_market",
    name: "Faerie Market",
    description: "You stumble upon a hidden faerie market, where glittering stalls float mid-air and the shopkeepers have an unsettling number of teeth in their smiles.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "store": null },
    imageId: "faerie_market",
    paths: [
      {
        id: "start",
        description: "Mischievous faeries flit about, eyeing your possessions with keen interest. What do you do?",
        kind: {
          choice: {
            choices: [
              {
                id: "acquire_trinket",
                description: "Try to acquire a magical trinket. Hope you're good at riddles and have a spare firstborn child.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { charisma: null } } },
                      description: "Your charm wins over a faerie shopkeeper. They hand you a trinket that's either a powerful artifact or a very shiny pebble.",
                      effects: [{ addItemWithTags: ["trinket"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "The faerie shopkeeper gets distracted by a passing butterfly. You leave empty-handed but at least you still have both your shoes.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "trade",
                description: "Offer to trade an item for faerie magic. What could possibly go wrong?",
                requirement: [{ itemWithTags: [] }],
                effects: [{ removeItemWithTags: [] }],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { wisdom: null } } },
                      description: "The faeries accept your trade with glee. You receive a magical item that thankfully isn't cursed. Probably.",
                      effects: [{ addItemWithTags: ["enchanted"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The faeries accept your trade but seem to have a different idea of 'magical' than you do. You now own a very sassy toadstool.",
                      effects: [{ addItemWithTags: ["fungus", "enchanted"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.2, kind: { raw: null } },
                      description: "The faeries reject your offer with a huff. At least they didn't turn you into a newt.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "use_crystal",
                description: "Use a crystal to curry favor with the faeries. It's like magical bribery, but sparklier.",
                requirement: [{ itemWithTags: ["crystal"] }],
                effects: [{ removeItemWithTags: ["crystal"] }],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.8, kind: { raw: null } },
                      description: "The faeries are dazzled by your crystal. They offer you a choice of their finest wares.",
                      effects: [],
                      pathId: ["crystal_success"]
                    },
                    {
                      weight: { value: 0.2, kind: { raw: null } },
                      description: "The faeries appreciate the crystal but seem more interested in using it as a disco ball for their impromptu dance party.",
                      effects: [{ addItemWithTags: ["footwear", "enchanted"] }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "leave",
                description: "Leave the market before you trade away your shadow or your sense of direction.",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      },
      {
        id: "crystal_success",
        description: "The faeries present you with a choice of their most prized possessions.",
        kind: {
          choice: {
            choices: [
              {
                id: "choose_armor",
                description: "Choose a piece of armor that's more glitter than metal.",
                requirement: [],
                effects: [{ addItemWithTags: ["armor", "enchanted"] }],
                nextPath: { none: null }
              },
              {
                id: "choose_trinket",
                description: "Pick a mysterious trinket of questionable usefulness.",
                requirement: [],
                effects: [{ addItemWithTags: ["trinket", "enchanted"] }],
                nextPath: { none: null }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "goblin_raiding_party",
    name: "Goblin Raiding Party",
    description: "A band of goblins emerges from the underbrush, brandishing crude weapons and eyeing your possessions. Their leader sports a 'World's Best Raider' hat that's clearly homemade.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "combat": null },
    imageId: "goblin_raiding_party",
    paths: [
      {
        id: "start",
        description: "The goblins are closing in, their grins revealing a concerning lack of dental hygiene. What do you do?",
        kind: {
          choice: {
            choices: [
              {
                id: "fight",
                description: "Engage the goblin raiding party in combat. Time to show them why 'adventurer' isn't just a fancy word for 'walking loot piñata'.",
                requirement: [],
                effects: [],
                nextPath: { single: "combat" }
              },
              {
                id: "bribe",
                description: "Offer some of your resources to appease the goblins. Maybe they accept credit cards?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { charisma: null } } },
                      description: "Your silver tongue (and shiny trinkets) convince the goblins to leave you alone. They even throw in a free 'I got robbed by goblins' t-shirt.",
                      effects: [{ removeItemWithTags: [] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "The goblins take your offering, then decide they want seconds. It's all-you-can-loot night, apparently.",
                      effects: [{ removeItemWithTags: [] }],
                      pathId: ["combat"]
                    }
                  ]
                }
              },
              {
                id: "intimidate",
                description: "Use your strength to scare off the goblins. Flex those muscles you've been working on at the Adventurers' Gym.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { strength: null } } },
                      description: "Your impressive display of strength sends the goblins running. One drops his 'World's Best Raider' hat in his haste.",
                      effects: [{ addItemWithTags: ["headwear"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The goblins seem more amused than intimidated. One of them even offers you workout tips.",
                      effects: [],
                      pathId: ["combat"]
                    }
                  ]
                }
              },
              {
                id: "distract",
                description: "Create a clever diversion to escape the goblins. Time to put those improv classes to use!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your brilliant diversion works! The goblins are now arguing over the finer points of your impromptu puppet show.",
                      effects: [],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "Your diversion fails spectacularly. The goblins give you a 2-star review and then ready their weapons.",
                      effects: [],
                      pathId: ["combat"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "combat",
        description: "The goblins attack! Their battle cry sounds suspiciously like 'Loot! Loot! Loot!'",
        kind: {
          combat: {
            creatures: [{ id: "goblin" }, { id: "goblin" }, { id: "goblin" }],
            nextPath: { single: "post_combat" }
          }
        }
      },
      {
        id: "post_combat",
        description: "With the goblin threat neutralized, you take a moment to catch your breath and check for loot.",
        kind: {
          reward: {
            kind: { random: null },
            nextPath: { none: null }
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "knowledge_nexus",
    name: "Knowledge Nexus",
    description: "You enter a floating library of ancient wisdom. Books zip through the air, occasionally bonking distracted readers on the head.",
    location: {
      // zoneIds: ["ancient_ruins"], TODO
      common: null
    },
    category: { "other": null },
    imageId: "knowledge_nexus",
    paths: [
      {
        id: "start",
        description: "The air hums with arcane energy, and you swear you can hear the books whispering secrets. What do you do?",
        kind: {
          choice: {
            choices: [
              {
                id: "study_magic",
                description: "Study ancient texts to expand your magical knowledge. Hope you brought your reading glasses!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                      description: "You successfully decipher an ancient tome. Your brain feels bigger, but your hat size remains the same.",
                      effects: [{ addItemWithTags: ["book"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The text is too complex. You end up reading 'Ancient Runes for Dummies' instead.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "learn_combat",
                description: "Learn new combat techniques from old battle manuals. Hopefully, they're not just elaborate dance instructions.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { strength: null } } },
                      description: "You master an ancient fighting technique. Your muscles now ripple with knowledge.",
                      effects: [{ addItem: "battle_manual" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { dexterity: null } } },
                      description: "You learn a set of defensive maneuvers. You can now dodge responsibility AND attacks!",
                      effects: [{ addItem: "evasion_scroll" }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "decipher_map",
                description: "Attempt to decipher an old map. It's either a treasure map or yesterday's lunch menu.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { wisdom: null } } },
                      description: "You successfully decipher the map, revealing the location of a hidden treasure. X marks the spot... or is that a ketchup stain?",
                      effects: [{ addItem: "treasure_map" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "The map remains a mystery. You're pretty sure you're holding it upside down, but it doesn't help.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "leave",
                description: "Leave the Knowledge Nexus. Your brain is full, and you can't remember where you parked your horse anyway.",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "lost_elfling",
    name: "Lost Elfling",
    description: "You hear the faint cries of a young elf, seemingly lost and separated from their clan. The sobs are punctuated by occasional hiccups that sound suspiciously like 'tree cookies'.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    imageId: "lost_elfling",
    paths: [
      {
        id: "start",
        description: "A tiny elf with leaves in their hair and a runny nose looks up at you with big, watery eyes. What do you do?",
        kind: {
          choice: {
            choices: [
              {
                id: "help",
                description: "Offer assistance to the lost elfling. Hope you're good with kids and have some tree cookies handy.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { charisma: null } } },
                      description: "Your charming demeanor calms the elfling. You successfully reunite them with their clan, earning eternal gratitude and a sticky hug.",
                      effects: [],
                      pathId: ["help_success"]
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "Your attempt to help turns into an impromptu game of hide-and-seek. Unfortunately, the elfling is winning.",
                      effects: [{ damage: { raw: 2n } }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "investigate",
                description: "Carefully investigate the area before approaching. Time to put on your detective hat and look for tiny footprints.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your careful investigation reveals a trail of breadcrumbs... er, acorns. You safely guide the elfling back to their clan.",
                      effects: [],
                      pathId: ["help_success"]
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "While investigating, you accidentally disturb a nest of angry pixies. They're small, but their pinches hurt!",
                      effects: [{ damage: { raw: 1n } }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "use_perception",
                description: "Use your keen perception to locate the elfling's clan. Time to channel your inner bloodhound!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.8, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your sharp senses lead you straight to the elfling's clan. They're impressed by your tracking skills and pointy ear envy.",
                      effects: [],
                      pathId: ["help_success"]
                    },
                    {
                      weight: { value: 0.2, kind: { raw: null } },
                      description: "Your keen perception leads you right into a patch of giggling mushrooms. Their spores make you see double... of everything.",
                      effects: [{ damage: { raw: 1n } }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "abandon",
                description: "Continue on your way, leaving the elfling to its fate. You're an adventurer, not a babysitter, right?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 1, kind: { raw: null } },
                      description: "You walk away, trying to ignore the sniffles behind you. Suddenly, you feel a tug at your heartstrings... or is that just indigestion?",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "help_success",
        description: "The elfling's clan showers you with gratitude and rewards. You're now an honorary elf, pointy ears pending.",
        kind: {
          reward: {
            kind: { random: null },
            nextPath: { none: null }
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "mysterious_structure",
    name: "Mysterious Structure",
    description: "You encounter a pyramid-like structure with glowing runes, overgrown by vines. A sealed entrance beckons. It's either an ancient temple or the world's most elaborate garden shed.",
    location: {
      // zoneIds: ["ancient_ruins"], TODO
      common: null
    },
    category: { "other": null },
    imageId: "mysterious_structure",
    paths: [
      {
        id: "start",
        description: "The structure looms before you, its runes pulsing with an eerie light. What's your move, Indiana Pains?",
        kind: {
          choice: {
            choices: [
              {
                id: "forceful_entry",
                description: "Attempt to create an opening using brute force. Who needs finesse when you have muscles?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { strength: null } } },
                      description: "Your mighty muscles prevail! The entrance crumbles before you. Let's hope the rest of the structure doesn't follow suit.",
                      effects: [],
                      pathId: ["explore_structure"]
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "Your forceful attempt backfires spectacularly. The structure remains intact, but your pride (and a few bones) might be bruised.",
                      effects: [{ damage: { raw: 3n } }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "decipher_runes",
                description: "Try to decipher the glowing runes. Time to put those ancient language classes to use!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your wisdom pays off! The runes reveal a secret entrance. Turns out it was just a really complicated 'Push to Open' sign.",
                      effects: [],
                      pathId: ["explore_treasure_room"]
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "Your translation seems off. Instead of opening, the structure starts telling bad jokes in an ancient dialect.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "sacrifice",
                description: "Offer a random item to the structure. Maybe it just wants a snack?",
                requirement: [],
                effects: [{ removeItemWithTags: [] }],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { raw: null } },
                      description: "The structure accepts your offering! A secret entrance opens. Apparently, ancient temples take bribes.",
                      effects: [],
                      pathId: ["explore_treasure_room"]
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "The structure gobbles up your item but remains closed. Looks like it's more of a picky eater.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "skip",
                description: "Ignore the structure and continue exploring. Not every mysterious ruin needs poking, right?",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      },
      {
        id: "explore_structure",
        description: "You venture into the mysterious structure. The air is thick with dust, mystery, and the faint smell of old socks.",
        kind: {
          choice: {
            choices: [
              {
                id: "cautious_explore",
                description: "Explore cautiously, keeping an eye out for traps. Channel your inner cat burglar!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your nimble feet and keen eyes help you navigate the structure safely. You feel like a graceful gazelle... in a dusty, ancient gazelle obstacle course.",
                      effects: [],
                      pathId: ["explore_treasure_room"]
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "Despite your caution, you trigger a trap. A cascade of pebbles falls on you. Not very dangerous, but very, very annoying.",
                      effects: [{ damage: { raw: 1n } }],
                      pathId: ["explore_treasure_room"]
                    }
                  ]
                }
              },
              {
                id: "reckless_dash",
                description: "Make a mad dash for the central chamber. Fortune favors the bold (and the impatient)!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.4, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your reckless sprint pays off! You reach the central chamber in record time, leaving traps and cobwebs in your dust.",
                      effects: [],
                      pathId: ["explore_treasure_room"]
                    },
                    {
                      weight: { value: 0.6, kind: { raw: null } },
                      description: "Your haste gets the better of you. You trip over your own feet and face-plant into a conveniently placed pile of ancient cushions.",
                      effects: [{ damage: { raw: 2n } }],
                      pathId: ["explore_treasure_room"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "explore_treasure_room",
        description: "You reach the heart of the structure. Surely untold riches await! Or at least some really old knick-knacks.",
        kind: {
          choice: {
            choices: [
              {
                id: "search_thoroughly",
                description: "Search the room thoroughly. Leave no ancient vase unturned!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.8, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your diligence pays off! You uncover a hidden cache of treasure. The 'X' on the floor wasn't subtle, but hey, a win's a win.",
                      effects: [],
                      pathId: ["treasure_found"]
                    },
                    {
                      weight: { value: 0.2, kind: { raw: null } },
                      description: "Despite your thorough search, you find nothing of value. Unless you count the priceless lesson about disappointment.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "grab_and_run",
                description: "Quickly grab whatever looks valuable and make a run for it. The 'Indiana Jones boulder' is probably already rolling.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your quick hands snag a valuable artifact! You make it out just as the temple starts to crumble. Cliché, but effective.",
                      effects: [],
                      pathId: ["treasure_found"]
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "In your haste, you grab what turns out to be an ancient chamber pot. Valuable to someone, sure, but not exactly treasure.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "treasure_found",
        description: "Against all odds, you've successfully plundered... er, 'archaeologically recovered' treasure from the mysterious structure!",
        kind: {
          reward: {
            kind: { random: null },
            nextPath: { none: null }
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "mystic_forge",
    name: "Mystic Forge",
    description: "You enter a magical smithy where the hammers swing themselves and the anvils occasionally burp fire. It's either a blacksmith's dream or a safety inspector's nightmare.",
    location: {
      // zoneIds: ["mystic_caves"], TODO
      common: null
    },
    category: { "store": null },
    imageId: "mystic_forge",
    paths: [
      {
        id: "start",
        description: "The forge crackles with arcane energy, and you swear the bellows just winked at you. What's your move, brave adventurer?",
        kind: {
          choice: {
            choices: [
              {
                id: "upgrade",
                description: "Attempt to upgrade your equipment. 60% of the time, it works every time!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { strength: null } } },
                      description: "The forge bellows with approval.",
                      effects: [{ addItemWithTags: ["enchanted", "armor"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "The forge hiccups. Your equipment remains unchanged, but now it smells vaguely of burnt toast. Progress?",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "reforge",
                description: "Reforge an item. It's like a makeover, but for swords! What could possibly go wrong?",
                requirement: [{ itemWithTags: ["armor"] }],
                effects: [{ removeItemWithTags: ["armor"] }],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your deft handling results in a successfully reforged item. It looks suspiciously similar but feels somehow cooler.",
                      effects: [{ addItemWithTags: ["enchanted", "armor"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your wisdom guides the reforging process. The result is an item of surprising utility, if questionable aesthetics.",
                      effects: [{ addItemWithTags: ["trinket"] }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "craft",
                description: "Attempt to craft a special item. Warning: May result in unexpected chicken statues.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                      description: "The forge erupts in a shower of sparks. You've created something... interesting. It's either a powerful artifact or a very shiny paperweight.",
                      effects: [{ addItem: "mysterious_artifact" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The forge burps loudly. You're left holding... is that a rubber chicken? Well, it's certainly special.",
                      effects: [{ addItem: "rubber_chicken" }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "leave",
                description: "Leave the Mystic Forge. The heat was getting unbearable anyway, and you're pretty sure that hammer was eyeing your kneecaps.",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "sinking_boat",
    name: "Sinking Boat",
    description: "You come across a small boat sinking in a nearby river. The passengers are calling for help, their cries punctuated by the occasional glub-glub of the boat.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    imageId: "sinking_boat",
    paths: [
      {
        id: "start",
        description: "The boat is taking on water faster than a sponge in a rainstorm. What's your heroic (or not so heroic) move?",
        kind: {
          choice: {
            choices: [
              {
                id: "heroic_swim",
                description: "Channel your inner fish and swim out to the rescue. Hope you remembered your floaties!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { strength: null } } },
                      description: "Your powerful strokes cut through the water like a majestic dolphin... if dolphins had arms and legs. You reach the boat in record time!",
                      effects: [],
                      pathId: ["rescue_success"]
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "Turns out, you swim like a rock. A very determined rock. You manage to reach the boat, but not before swallowing half the river.",
                      effects: [{ damage: { raw: 2n } }],
                      pathId: ["rescue_success"]
                    }
                  ]
                }
              },
              {
                id: "clever_rescue",
                description: "Use your wit to devise a clever rescue plan. Time to put those 'MacGyver' skills to the test!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your brilliant mind conjures up a plan involving a long vine, three acorns, and a surprisingly cooperative squirrel. Against all odds, it works!",
                      effects: [],
                      pathId: ["rescue_success"]
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "Your 'foolproof' plan involves a makeshift catapult. Unfortunately, you miscalculated and launched yourself into the river instead of a rescue rope.",
                      effects: [{ damage: { raw: 1n } }],
                      pathId: ["rescue_success"]
                    }
                  ]
                }
              },
              {
                id: "charm_river",
                description: "Try to charm the river into calming down. Who says you can't negotiate with nature?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { charisma: null } } },
                      description: "Miraculously, the river seems to listen! The waters calm, allowing for an easy rescue. You're either a smooth talker or the river spirit was in a good mood.",
                      effects: [],
                      pathId: ["rescue_success"]
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "The river is unimpressed by your sweet talk. In fact, it seems to get a bit rougher. Did you just trash-talk a body of water?",
                      effects: [],
                      pathId: ["rescue_challenge"]
                    }
                  ]
                }
              },
              {
                id: "ignore_situation",
                description: "Pretend you don't see anything. Those swimming lessons are finally paying off... for someone else.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 1, kind: { raw: null } },
                      description: "You walk away, whistling innocently. Suddenly, you feel a tug at your conscience... or maybe it's just indigestion from that questionable tavern food.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "rescue_success",
        description: "Against all odds (and possibly the laws of physics), you manage to rescue everyone from the sinking boat!",
        kind: {
          choice: {
            choices: [
              {
                id: "accept_reward",
                description: "Accept the passengers' gratitude and any reward they might offer. Hero's gotta eat!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { raw: null } },
                      description: "The grateful passengers reward you with a mysterious artifact they fished out of the river just before the boat started sinking. It's either a powerful magical item or a very wet piece of driftwood.",
                      effects: [{ addItem: "mysterious_artifact" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The passengers thank you profusely and offer you... a slightly damp sandwich. It's the thought that counts, right?",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "humble_departure",
                description: "Refuse any rewards and dramatically disappear into the forest. Legends say they still tell tales of the mysterious river savior.",
                requirement: [],
                effects: [],
                nextPath: { none: null }
              }
            ]
          }
        }
      },
      {
        id: "rescue_challenge",
        description: "The rescue just got more challenging. Time to get creative or get wet!",
        kind: {
          choice: {
            choices: [
              {
                id: "daring_dive",
                description: "Take a deep breath and make a daring dive into the turbulent waters. It's hero time!",
                requirement: [],
                effects: [{ damage: { raw: 2n } }],
                nextPath: { single: "rescue_success" }
              },
              {
                id: "improvise_raft",
                description: "Quickly improvise a raft from nearby debris. Your arts and crafts skills are about to be put to the ultimate test.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your hastily constructed raft holds together just long enough to reach the sinking boat. MacGyver would be proud!",
                      effects: [],
                      pathId: ["rescue_success"]
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "Your 'raft' falls apart faster than a sandcastle in a tsunami. At least you now have a new appreciation for shipwrights.",
                      effects: [{ damage: { raw: 1n } }],
                      pathId: ["rescue_success"]
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "trapped_druid",
    name: "Druid in a Pickle",
    description: "You stumble upon a druid entangled in a pulsating magical snare. The vines seem to be... singing? This is either a very strange trap or the world's worst botanical boy band.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    imageId: "trapped_druid",
    paths: [
      {
        id: "start",
        description: "The druid looks at you pleadingly, while the magical vines continue their off-key serenade. What's your plan, oh brave adventurer?",
        kind: {
          choice: {
            choices: [
              {
                id: "brute_force",
                description: "Channel your inner lumberjack and try to muscle through the magical vines. Who needs finesse when you have biceps?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { strength: null } } },
                      description: "Your impressive display of strength intimidates the vines into submission. They release the druid and slink away, looking thoroughly embarrassed.",
                      effects: [],
                      pathId: ["druid_freed"]
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "The vines take offense to your rough handling and decide to give you a tight hug too. Congratulations, you're now part of the world's strangest group hug.",
                      effects: [{ damage: { raw: 2n } }],
                      pathId: ["both_trapped"]
                    }
                  ]
                }
              },
              {
                id: "nature_whisperer",
                description: "Attempt to communicate with the vines. Maybe they just need a friend... or a good therapist.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your soothing words calm the vines. They release the druid and curl up for a nap. You've just become a magical plant whisperer!",
                      effects: [],
                      pathId: ["druid_freed"]
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The vines misinterpret your attempt at communication as an audition. You're now the lead singer of 'The Tangled Tendrils'. The druid looks unimpressed.",
                      effects: [],
                      pathId: ["singing_contest"]
                    }
                  ]
                }
              },
              {
                id: "clever_solution",
                description: "Look around for a clever solution. Time to put those escape room skills to use!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { dexterity: null } } },
                      description: "You notice a conveniently placed pair of magical pruning shears. With a few snips, you free the druid. The vines applaud your gardening skills.",
                      effects: [],
                      pathId: ["druid_freed"]
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "Your 'clever' solution involves using a nearby beehive as a distraction. Now you have angry bees AND clingy vines. Great job, Einstein.",
                      effects: [{ damage: { raw: 1n } }],
                      pathId: ["chaotic_situation"]
                    }
                  ]
                }
              },
              {
                id: "leave_alone",
                description: "Decide this is above your pay grade and walk away. You're an adventurer, not a botanist!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 1, kind: { raw: null } },
                      description: "You start to leave, but your conscience nags at you. Or maybe it's the druid's disappointed sighs. Either way, you feel guilty... and slightly less heroic.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "both_trapped",
        description: "Great, now you're both trapped. At least you have company for this impromptu botanical cuddle session.",
        kind: {
          choice: {
            choices: [
              {
                id: "combined_effort",
                description: "Work together with the druid to escape. Two heads are better than one, especially when they're both wrapped in vines!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.8, kind: { attributeScaled: { charisma: null } } },
                      description: "Your teamwork is impressive! You and the druid manage to outsmart the vines, freeing yourselves with minimal embarrassment.",
                      effects: [],
                      pathId: ["druid_freed"]
                    },
                    {
                      weight: { value: 0.2, kind: { raw: null } },
                      description: "Your combined efforts only seem to entangle you further. On the bright side, you've just invented a new form of extreme yoga.",
                      effects: [{ damage: { raw: 1n } }],
                      pathId: ["rescued_by_squirrels"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "singing_contest",
        description: "The vines challenge you to a singing contest. Winner gets to keep the druid... wait, what?",
        kind: {
          choice: {
            choices: [
              {
                id: "accept_challenge",
                description: "Accept the challenge. It's time to show these vines who's the real star of this forest!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { charisma: null } } },
                      description: "Your rendition of 'Leaf Me Alone' brings tears to the vines' nonexistent eyes. They release the druid and offer you a record deal.",
                      effects: [],
                      pathId: ["druid_freed"]
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "Your singing is so bad, it actually works! The vines release the druid and flee in terror. Music critics everywhere feel a disturbance in the force.",
                      effects: [],
                      pathId: ["druid_freed"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "chaotic_situation",
        description: "Congratulations, you've turned a simple rescue into utter chaos. The druid looks both impressed and concerned.",
        kind: {
          choice: {
            choices: [
              {
                id: "embrace_chaos",
                description: "Embrace the chaos! If you can't beat 'em, join 'em. Time to dance with bees and sing with vines!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your chaotic dance moves confuse the bees and entertain the vines. In the commotion, the druid manages to slip free. You're either a genius or incredibly lucky.",
                      effects: [],
                      pathId: ["druid_freed"]
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "Your 'embrace the chaos' strategy backfires spectacularly. Now you're starring in a very weird nature documentary.",
                      effects: [{ damage: { raw: 2n } }],
                      pathId: ["rescued_by_squirrels"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "rescued_by_squirrels",
        description: "Just when all hope seems lost, a team of highly trained rescue squirrels appears! They quickly free you and the druid, then demand payment in nuts.",
        kind: {
          choice: {
            choices: [
              {
                id: "pay_squirrels",
                description: "Thank the squirrels and offer them some nuts from your pack. It's a small price to pay for freedom!",
                requirement: [],
                effects: [],
                nextPath: { single: "druid_freed" }
              },
              {
                id: "negotiate_with_squirrels",
                description: "Try to negotiate with the squirrels. Surely they accept acorns on credit?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { charisma: null } } },
                      description: "Your smooth talking impresses the squirrels. They agree to a payment plan of one nut per week. You've just entered the exciting world of rodent finance!",
                      effects: [],
                      pathId: ["druid_freed"]
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "The squirrels are unimpressed by your negotiation skills. They leave in a huff, but not before pelting you with acorn shells. Talk about tough creditors!",
                      effects: [{ damage: { raw: 1n } }],
                      pathId: ["druid_freed"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "druid_freed",
        description: "Against all odds (and possibly logic), the druid is finally free! They look at you with a mixture of gratitude and bewilderment.",
        kind: {
          choice: {
            choices: [
              {
                id: "accept_reward",
                description: "Accept the druid's thanks and any reward they might offer. Saving people from musical vines isn't a cheap business!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { raw: null } },
                      description: "The druid rewards you with a mysterious seed. They claim it will grow into a mighty artifact, or possibly just a very talkative houseplant.",
                      effects: [{ addItem: "mysterious_seed" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The druid thanks you profusely and offers you... a coupon for a free hug from a tree of your choice. It's not much, but it's honest work.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "request_lesson",
                description: "Ask the druid for a quick lesson in dealing with magical plants. Knowledge is power, after all!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 1, kind: { raw: null } },
                      description: "The druid gives you a crash course in magical botany. You now know how to properly address a venus flytrap and the best fertilizer for moon flowers. This information will surely come in handy... someday.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "travelling_bard",
    name: "The Bard's Bizarre Ballads",
    description: "You encounter a bard whose lute is suspiciously in tune for someone who's been on the road. His hair is perfectly windswept, and you swear you can hear a faint background orchestra.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    imageId: "travelling_bard",
    paths: [
      {
        id: "start",
        description: "The bard strikes a dramatic pose and announces, 'Greetings, weary traveler! Care to partake in the melodious adventures of Filburt the Fantastic?' What's your move?",
        kind: {
          choice: {
            choices: [
              {
                id: "duet_challenge",
                description: "Challenge the bard to a duet. Two can play at this game... literally.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { charisma: null } } },
                      description: "Your impromptu duet with the bard creates magic... literally. Small sparkles appear in the air, and nearby trees start swaying to the rhythm.",
                      effects: [{ addItem: "harmonic_charm" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "Your attempt at harmonizing causes nearby wildlife to flee in terror. The bard looks impressed, but not in a good way.",
                      effects: [],
                      pathId: ["music_lessons"]
                    }
                  ]
                }
              },
              {
                id: "request_epic",
                description: "Ask the bard to compose an epic ballad about your adventures. Time to become a legend... or at least a decent limerick.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                      description: "The bard weaves a tale so captivating that reality itself seems to bend. You feel more heroic already, and is that a new skill you've suddenly mastered?",
                      effects: [{ heal: { raw: 10n } }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The bard's epic ballad about your adventures is... less than flattering. Apparently, your heroic dragon slaying was more like 'mildly inconveniencing a large lizard'.",
                      effects: [],
                      pathId: ["reputation_management"]
                    }
                  ]
                }
              },
              {
                id: "dance_off",
                description: "Challenge the bard to a dance-off. If you can't beat the music, become the music!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your sick moves impress even the trees. The bard declares you the winner and rewards you with a pair of magical dancing shoes.",
                      effects: [{ addItemWithTags: ["footwear", "enchanted"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "Your dancing is so bad, it's good. The bard can't stop laughing and offers you a job as a comedy act.",
                      effects: [],
                      pathId: ["comedy_career"]
                    }
                  ]
                }
              },
              {
                id: "ignore_bard",
                description: "Attempt to ignore the bard and continue on your way. Good luck with that!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 1, kind: { raw: null } },
                      description: "As you try to leave, you find yourself inexplicably moonwalking back towards the bard. Seems like the power of music is strong with this one.",
                      effects: [],
                      pathId: ["musical_curse"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "music_lessons",
        description: "The bard, both amused and concerned, offers to give you a quick music lesson.",
        kind: {
          choice: {
            choices: [
              {
                id: "accept_lessons",
                description: "Swallow your pride and accept the lessons. It's time to face the music!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.8, kind: { attributeScaled: { wisdom: null } } },
                      description: "The bard's lessons work wonders. You may not be a virtuoso, but at least you no longer sound like a cat in a blender.",
                      effects: [{ addItemWithTags: ["instrument"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.2, kind: { raw: null } },
                      description: "Despite the bard's best efforts, your music remains a threat to public safety. He gives you a 'participation trophy' and some earplugs.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "reputation_management",
        description: "Your less-than-heroic ballad is starting to spread. Time for some damage control!",
        kind: {
          choice: {
            choices: [
              {
                id: "embellish_truth",
                description: "Try to convince the bard to embellish your tales. A little creative license never hurt anyone, right?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { charisma: null } } },
                      description: "Your silver tongue works its magic. The bard crafts a new ballad that paints you as a misunderstood hero. Your reputation is saved, and possibly improved!",
                      effects: [],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "Your attempt at embellishment backfires. Now you're known as both a bumbling adventurer AND a shameless self-promoter. At least you're famous?",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "comedy_career",
        description: "The bard suggests you could have a bright future in comedy. Are you ready for the spotlight?",
        kind: {
          choice: {
            choices: [
              {
                id: "embrace_comedy",
                description: "Embrace your newfound comedic talent. If you can't beat 'em, make 'em laugh!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { charisma: null } } },
                      description: "Your first comedy show is a smashing success! You're now the proud owner of a 'Laughing Lute', which adds a chuckle to every adventure.",
                      effects: [{ addItem: "laughing_lute" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "Your jokes fall flatter than a pancake in a black hole. The bard consoles you and suggests sticking to your day job... whatever that is.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "musical_curse",
        description: "Congratulations! You're now cursed to spontaneously burst into song at inappropriate moments. The bard looks both apologetic and amused.",
        kind: {
          choice: {
            choices: [
              {
                id: "embrace_curse",
                description: "Embrace the musical curse. If life's going to be a musical, you might as well be the star!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.8, kind: { attributeScaled: { charisma: null } } },
                      description: "You lean into the curse with gusto. Your spontaneous musical numbers become the stuff of legend, and you gain a magical microphone that amplifies your voice in battle.",
                      effects: [{ addItem: "bardic_microphone" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.2, kind: { raw: null } },
                      description: "Your enthusiasm for the curse is... not shared by others. You're now known as 'that weird singing adventurer'. On the bright side, you always have a backup career as a town crier!",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
  {
    id: "wandering_alchemist",
    name: "The Wandering Alchemist",
    description: "You stumble upon a wild-eyed alchemist, their hair frazzled and eyebrows slightly singed. Their pack bubbles and fizzes ominously, occasionally letting out small puffs of rainbow-colored smoke.",
    location: {
      zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    imageId: "wandering_alchemist",
    paths: [
      {
        id: "start",
        description: "The alchemist spots you and grins maniacally. 'Ah, a test subject... er, valued customer! Care to dabble in the delightful dangers of alchemy?' What's your move?",
        kind: {
          choice: {
            choices: [
              {
                id: "taste_test",
                description: "Volunteer as a taste tester for the alchemist's latest concoction. What could possibly go wrong?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { strength: null } } },
                      description: "You down the bubbling liquid and feel a surge of power! Your muscles bulge, and you can suddenly hear colors. Side effects may include occasional sparkly burps.",
                      effects: [{ addItemWithTags: ["potion"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "The potion turns you into a small, confused chicken. The alchemist assures you it's temporary... probably.",
                      effects: [],
                      pathId: ["chicken_adventure"]
                    }
                  ]
                }
              },
              {
                id: "assist_experiment",
                description: "Offer to assist the alchemist with their next experiment. Science needs brave volunteers!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your insightful suggestions lead to a breakthrough! The alchemist creates a revolutionary potion and shares it with you.",
                      effects: [{ addItemWithTags: ["potion"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.3, kind: { raw: null } },
                      description: "The experiment goes haywire, covering you both in a sticky, glowing goo. On the bright side, you'll never need a nightlight again!",
                      effects: [{ addItemWithTags: ["potion"] }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "challenge_alchemist",
                description: "Challenge the alchemist to an alchemy-off. It's time to see if you can out-brew the pro!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.5, kind: { attributeScaled: { dexterity: null } } },
                      description: "Your quick hands and creative mixing impress the alchemist. They declare you a natural and gift you a special brew.",
                      effects: [{ addItemWithTags: ["potion"] }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.5, kind: { raw: null } },
                      description: "Your attempt at alchemy creates a small, harmless explosion. The alchemist gives you an 'A' for effort and a fire-resistant apron.",
                      effects: [{ addItem: "fireproof_apron" }],
                      pathId: []
                    }
                  ]
                }
              },
              {
                id: "polite_decline",
                description: "Politely decline and try to leave. Emphasis on 'try'.",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 1, kind: { raw: null } },
                      description: "As you turn to leave, you trip over a stray root and fall face-first into a patch of strange mushrooms. Things are about to get... interesting.",
                      effects: [],
                      pathId: ["accidental_trip"]
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "chicken_adventure",
        description: "Congratulations! You're now a small, confused chicken. But every cloud has a silver lining, right?",
        kind: {
          choice: {
            choices: [
              {
                id: "embrace_chicken",
                description: "Embrace your new chicken life. It's time to rule the roost!",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.8, kind: { attributeScaled: { charisma: null } } },
                      description: "You become the most charismatic chicken in history. The alchemist, impressed by your adaptability, turns you back and rewards you with a special egg.",
                      effects: [{ addItem: "egg_of_transformation" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.2, kind: { raw: null } },
                      description: "You spend an hour as a chicken before turning back. The experience was... enlightening. You now have an odd craving for seeds and a newfound respect for poultry.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      },
      {
        id: "accidental_trip",
        description: "Those weren't ordinary mushrooms. The world around you starts to swirl with impossible colors and talking flowers.",
        kind: {
          choice: {
            choices: [
              {
                id: "go_with_flow",
                description: "Embrace the hallucinogenic journey. When in Rome, right?",
                requirement: [],
                effects: [],
                nextPath: {
                  multi: [
                    {
                      weight: { value: 0.6, kind: { attributeScaled: { wisdom: null } } },
                      description: "Your mushroom-induced vision quest leads to profound insights. You come back with knowledge of a rare alchemical recipe.",
                      effects: [{ addItem: "recipe_of_enlightenment" }],
                      pathId: []
                    },
                    {
                      weight: { value: 0.4, kind: { raw: null } },
                      description: "You have a delightful conversation with a talking tree, only to 'wake up' and realize you've been hugging the alchemist for the past hour. How embarrassing.",
                      effects: [],
                      pathId: []
                    }
                  ]
                }
              }
            ]
          }
        }
      }
    ],
    unlockRequirement: []
  },
];