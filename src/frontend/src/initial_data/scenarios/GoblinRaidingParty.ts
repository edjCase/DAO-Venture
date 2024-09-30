import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData =
{
    id: "goblin_raiding_party",
    name: "Goblin Raiding Party",
    description: "A band of goblins emerges from the underbrush, brandishing crude weapons and eyeing your possessions. Their leader sports a 'World's Best Raider' hat that's clearly homemade.",
    location: {
        zoneIds: ["enchanted_forest"],
    },
    category: { "combat": null },
    image: decodeBase64ToImage("ZHd9KYCILXiAL2NtJlVgNElPMD5YS0pWLmdrMVJcMkRJLFRdMl1nMjszJTU8K1VWLS0zKUFFLU5RLUBPPk1cPm58ODg1LklKL05SMCgtLSwmIneAMkdGKysyKC8tIiwhIz5GMDtDKmJsRG2AR0NBLzZBNkNJLzQ9MmFxO1dqPi0zNB8fHT9JO05ePj9HLkZUOEROOERROycdHklWO0NWO0tVOTg+Nj5DM19nNTg+NE9YNFBFLj1BNVFONmBIOGNhPVVaPUdRNVZkPlpmOl1LOEZFLWZwOVZjN0ZONURNPURHPEVDN1JELElPOFJaOUlTMlRXL0JMNFJcN19pNUtSM1hnNV9fOUJCI0hPNFtjNlZdO2VtPFZZM1ZSMU9TMlhkNVlgNlRdN1NXNE9TNgQAFAECAgIAAwMBBAEFBAYDBwEAAQIEAQECEQEEAAEBAQABCAEDDwEBAAECAggEAAEHAQkEBgEKAQcBCwECDQEBAAIBAQgGAQEAAQUBCAECAQEBAgEMAQ0BDgENAwEBDwEBAQIHAQEAAxABCgERAgABEgELAQUCEwEGARQBCQEVAQABAwEBAQABDAIAAQIBAQECAg8CAQEPAQgBFgEXARgCAQEAAgECGQEaARsBAgEcARoBDQEZARABHQIBAQADEAIBARABHQIBAQIEEAEOARAEBwEGARMBBgEUAQgBAAECAgABAwIKAQUBCwEBAQICDAEAAQMBEAEdARoCEAECAgEBHgECAR8BGgEfARoBAgEeARoBDQQQAgEEEAEMAxABHQUQAQ4CEAEFAQcBIAQGAgcBDAIHAiEBDgEiASMBAgEhAg4BCwUQAh0BEgEaAhkEHwIZARoBJAMQARkCHQ0QAw4BJQEhASYBEwMGASYEBwEhASUCJwEjASgBAAEpAScBDgIQASoBEAIZARABHQIZARoBGQQfARkBKwEaAR8BEAEdAxkPEAEOASUBLAMTBAYBLQEmAQcBLgEvATABMQUjAQ4CJwEQAR0CEAEZARoBEAQZBB8BGQEyAQ0CHQMZAyoCEAEZAicBGQEqBRADJQEsBBMCBgMtARQBIgEUATMBNAYjASkBJQEpAhkBEAEGAScBGgEZARoBGQcaBRkCKgEnAioCGQEqARkBKgInASoBEwEsARACJQIsARMEBgItBCkBMAI0ByMCKQEGARkBEAIGAR8DGgEZARoCGQIaARkBKgIZASoBGQMnASoEGQIlAScCJQEsARMBLAElAywCEwQGAi0BKQEiASkBIwEnATQBMQEiBSMBIgIpASoBEAIGARkBGgIeAhoCGQEaARkBKgMZASUCKgInAxkHJQMTASwBBgMTBQYDKQEiAiMBFAI0ATMBFAIjASkBKgEtASkCBgEqASwCBgEaAg0BHgEZAx4BGgEqAhkBEAEnASoCJQMZAScCLAETASwDEwEGAhMBJQIsARMGBgMpBSMBLAEzATQCIwEOATUBLQIGASkBNgEqAgYBGgMNARkBHgENAR4BGQEqARkBEAEZAioBJQQZBCUCLAITAQYDEwIsARMHBgEtByMBNwE0ASIBHQEFARUBGwEDASkCBgEqASUBJwEZAQ0BJAENARkBDQEkAQ0BGQIqARkBEAEqAiUDGQE4ASUBLAIlAxMFBgMTBwYBKQgjASwBHQEHAQgBAQEbARUBOQMGARkBKgEZARYCJAEZAQ0BJAENARoBKgEQAhkBKgIlAhkBDAEBASwDJQITBgYCEwEsBwYJIwEQAToFAQEMAQUDBgEqARkBDQIkARoBDQE7ASQBDQMqARkDJQEZAQ4CAQEPASwBJQMTAQYBEwUGASwBEwcGCSMBPAEVARsEAQEbASEDBgEZAQYBGQIkARkBDQE7AT0BJAIqARkBKgIlARkBIQEbAgEBAwEQBBMBBgETBgYCLAYGAS0DIwE+AT8BIgFAARoBQQYBAUIBQwEzAUQBAQEbAQYBEAEkATsBGQEWATsBPQFFAxABKgElASoBJgFGBAEBDAEGAxMBBgETBgYBJQETAwYBEwIGAS0CKQIjAj8BAQEWAUcEAQEjAQEBSAFGAgEBPwEWAQYBHgEkATsBGQEWAUkBLAFKAxkCKgEgARUFAQEIAQ4BBgITAQYBEwcGASwBEwIGASwBBgItAQYBLQEpAiMBSwE/AUwBRwEQARoBIwFDAkwBKQFIAT8BGwEWAgYBGgI7ARkBFgETASwBTQIqAxkBBAEVBgEBDAEGAhMBBgETBwYCEwIGASwFBgIpAiMBPgFAATkBLwE5AUcBLwEOASABIwEdAUwBRAMGASICJAEZARYBIwETAS0BPgEBARQBMwE2ASgHAQEFARABEwsGASwCBgETBQYBKQEiASkCIgFLATUCAQE/ARsCAQFHATkBNgEGARkBJQEjAyQBGQIjAT8CBgEbAgEBOgFOBwEBTwEoASMCAQEjCAYBJQIGARMFBgQpASIBKwERASABKAMBAUcBJwERAQsBUAEIATMBGgEWASQBFgEZARYBIwEsAhMBEAI/ARYBNQFCASADAQEOASMBUQIBAT8BEwEGARMHBgElAgYBEwgGASIBGQEWAREBEAEaAScBNQEQAQ4BEAEIAQMBAAEMAhkBEAIkARkBEAEjARkCEwE5AT8BRAFSASMBTAE+ARoBIgEfAT4BUwEQAT8BGwFMAhMCBgITAwYBEwElAgYBLAkGAR8BIQEFAR0CEAEaAScBOQEWARICGwEAATkBGQEQAiQBGQEQASMBEAEnARoBJAENARkBKwFSAgEBPwQBAQ0BTAFLBxMCBgETASwBJQMTCQYBDgEhAQoBIQI8AT8BLwEVAQ0BDwEDAxUCAQEVARYBGQEQASMBGQEnAQ0CDwEkARABKwEoBAEBKAErAhwBGgcTAQYDEwElASwBJQE3AVQBEAcGASsCFgEhASgBIwEUARsBAQEeASQBDgErAScBFgEoAQEBJAEWARkBEAFLARYBGgEcAQMBAAEPAQcBEAErATUBKAFTASABGgEQARIBDAEPAQ0JEwEsAScCOQEIAQEBQwETBwYBEwEWARABKAEVAUIBGwIBARYBHQEyAR8BFgEbAUYBEAEWARkCRAEaATEBAwEPAQMBHAFVAQ4BHQErAU8BDgEZAR0BIQELAQMBHAEGCRMDLAEJAQACAQE3BwYBJwEWAR8BNwFHAU8BNQJTAS4BFgIyAUwBPwE7AhABHwE/AkQBGQFFAQgBAwENAVUBUgEOAR4DEAEmAQ4CAwEeAhMCLAITAiwCEwEsARYBGAICAgEBCAEQBgYBJQEgARkBIQEHAQsBBAFVAQkBBQEOATIBKwE7AVYBDQEQASUBRAEaATsBDQEZASoBMgErAR4BVQEBAUcBGgFXARwBUwEHAg0BDwEkBBMDLAETASwCEwERAQQBAgQBAQwBHgIWAwYBKQEQARYBIQEmAQkBUwEHAQQBIQEWATIBHgFEATsCGQElASQCDQFKARYBLQE5ARoBMgE5AwEBUQFEARIBDAErARoBEAEGAxMFLAETASwBGQEHASgBGwUBAQUBMgEaAwYBUgEqARABDgE6AQUBBwEJAQUBHgE7AUsBPQE/ASQCGQElAhYBOwE1ATwBIQMrARABUgEoARsBKAEmAQ0BHAEaAQ4BOQEGARMILAETATYDFQUBAUMCRgEwARMBBgE0ARYBMgENASQBPwEkAT8BHgENATsBGwIVARoCGQElAScBHgENATcBSAENAisBGgEnAU8DAQEoAToCKwEOAUEBJQETAiwBEwEsARMCIwEiAUIBMQFHARsGAQE1AT8BFQIBAT8BOQEfARoBHwENAj4BTAENAR8BRAEVAQgBDAENARkBKgInARoBOwIWATICKwEyARABQQFDARUBUwEJAS4BHwErAQ4BRwEZAiUBLAITASwCEwE/AQEBPgEgBwEBUQEbAQECGwEAATABOwENARoBHwI+AQ0BGgENASQBHgEkATsBGgEQAicBDgENAUQBDQErAR8CMgEaAQ0BWAEoAUMCWQE7AQ0BHgEQAUEBWgEQAkQFEwEeATsBTAEsASgBIwEBARsBQwEOASABMgE+AT8BCAICAjsDDQIaAR8BDQFMAR4BRQEeAR8BMgEqAicBEAFEARsBFQEjARoDMgINASQBWwE/AUwCDQEfATkBHgEkAkQBDQETAywBEAEeAR8BPgEeATMBGQEOASgBEAE8AUcBFgE+AR4BDwEAAQMBRwEeAUQCDQFMARwCTAEaASEBGgFFAQ0BGgEqAScBKgEsASQBXAE/AQ0CPgEaAQ0BHgINAT8BDQEaATIBGgEfARoBDgENAUQBTAErAhMCLAEyAR4BDwFXAQ0CAQFVBAEBKwEeAVcCDwExASYBGwE7AQ0CRAFdAUQBHgFIAgEBHwINAR8DJQE7AVYBOwEyATsBTAEaAQ0DMgFbASMBDQEeARIBVwEcAR8BGgIkAQYDEwEsARABDAEPAg0BFgEoARUCAQFDAR8BGgIcARIBGgEnASYBPwI3AR8BDQFEAR4BUQFDAgEBTgEfAQ0BHgIlAScBEAEWASQBGQEyAR4BMgENARoBXQE7ARoBHwESARwBHgFEAV0BDQElARUBRgFEBBMBPANXAQ0BHwErAVEBQgFRAR8BGgEeAUwCVwEnATIBJgE/AUEBOQIaAkwBNwFCAgEBLwEnAR8BDQIOAiUBHgENATIBHwEyAQ0BHwEcAQ0BVgQIAVcBHgFXAVYBGgIEAT0EEwEjAQEBXgEeAQ0BGgMrARABHQEOARoBTAFXATIBJwEeAkQBEAEWARABMgENAUwBEAE1AgEBKAEaARABGgEeAicBNwEeASQBKwEyAhoBKQFdARwBDQIIAVcBCAENASMBGgFWAUwBBAEWAVwBJAITAQEBRgFIAisCMgEQAQ4BEAEgAiEBHgEaAjIBJwEyAkQBPAEWARkBLAE8ASQBKgEQARUBAQFDARoBJwEQARoDLAEWASQBKwEyATwBFQEoA0QBDQFdAQ0BVgFdARsBKAEfAVEBQgErATsCEwEVAQMBHAMrAjIBGgIdAQUCDgEeAR8BMgErARABOQE9AUQCEAEZAicBKgEQARoBWgFIATMBUQEQATcCIAI3ARYBDQIyASgBAQEVAkQBXQEsARYBMgEkASADAQE8ARYBQAE9ARMBJwE4AQEBPwEeASsBMgIfAjIBGgMfARoBHwEyAR4CFQIbARQCGQQqATICEAE3ARoBEAEwAlECIAEWAR4BJQEyASMBAQEoAUsBNwFLARMBMAFRATIBIAEEAgEBFgEsAVECLAEfATsBRAEjAUQBHgIyARoCHwENAh4BDQEyAR4BDQEaAT8BGgFWAT8BMQE8ASUBEAEqASsCKgIZAR4BGgIQAVEBSAEgASECEAElATcCAQEtBCwCMQFRATwBVAEBASMBGgEsATcDUQEkAj8BDQIyAR8DMgEjAQ0BHwEyATsBTAEeATIBOwEaAT0BVgEaARABGQEQAR0CGQE5ASoCHgEaAhABWAEFAiACEAEaATcBAQEbASgCOQIgBFEBTgEbAQEBEAVRARoBOwFWARUBAQMjASIBNgEqATsBJAENAUwBDwE4Ag0BTQFLASQEEAIdAhkBEAIeARoCEAEmAU8CNwIQARkBOQEjAVoBMAEZATcDIANRATkBOgEoATEBNwFRAS8CQQEWATgBCAEBAT4CHwEeAQ0DTAFEARoBOgIBAUkBMgEfBRABHQIQAR0BEAEdAg0BHgEQATcCTwInAhACGQE5ATcBHwIQAiADUQE5ARYBUQEmATABKwJPAkEBGgFEAV0BRgEkAT4BKgE3AUsBDQEkAUwBXQEeARUCAQFCATAHEAUdATsBXQE9ATwCQQFPAUgBUQE8ARACGQEaARkGEAInATICFgE9ATIBLwJPAVQBLgEgARYBJAFWAkQCIwIsAR4BJAFMAR0BWgEJAQEBWAErAxABIAEmAUEBWAE1BB0BOwI4AT0BJgE6AQkBUQEnAhABHQIaChADGgIOAk8BNQEuASABFgEQATIBHwEWARAEUQE3ASYBPAE5AUEBQwEgAVoCEAEdAToBTwFDAUcBXwEEAVIBWAEZASQBCAEVAT8BHwEJAToBNwE1ATcBEAEdARYBDQEZCRABGgINAw4GIAEQAR8BGQMQAQ4BJwEwAVEBGgE3AR4BUQFEARYBKwEgAV8CDAZfAQQBJAFWAVsBDQFgAQsBCQEOAlIBFAE7AT0BDQoQARYBJAENAQ4BEAEOARABIAIhAiABNwMQAx0CEAFRARABMgENAiQBHwEQAU8BWQIMATgBKAQMAV8BOwEcAVYBDQEJAVMBCwE3AVQBBAE7AUYBPwENAUgBNQFSAjoEEAEdASQBVgFdAxABNQFBBCABHQEQAh0BEAUdARABHQMaAhABCQE4AwwBVQFfAQwDFQFGAQwBJAEhAToBGAFbAVQBJgFgATsBWwE/AQ0CYAFZAl8BUQEhARABGQEQARYBFQFGARYBEAE3ATgBDAMhATkMHQEaAQ0BGgIQBwwCCwMVAUYBBAE6AVEBTwFHAToBVAE6ASQBFQEbATsBBAFZAV8CDAELAVIBOgEWAR0BHgFWARsBVgFEA1MBOAFTAVEEHQEwAh0BOQQdATIBDQFEATsBEAEuAUYBFQMMAhUBWQEEAQsBXgELA18BVAFhAToCJgE6AQQBOAEVAQQBYAEEAWABGwEMBAgBRgEaAT0BFQE4AVsBXQJTBQgBRgIIAVMBOAFZARAEHQE7AQgBVgE3AQsBCAFGAVMBCAJGAQgCRgFfAVIBVAEEAUcBXwE6AWEBOgEgAUgBOgELAQ0BCwIEAQkBBAEbAVMDRgEIAUYBYAEeATsBRAEBAQ0BUwEIAVMDCAJGAQgDRgIIAVwBXgE6AR0BDQEbARUBOAFGAwgBRgEVAVkDDAFZAUMBCQELAQQBXwFSAToBOQFNATcBJgELAVABKAELAWABCwFTAV8BUwEMAQgFRgEVATsBWwEXAUYDCAFgAhUBGwEVAggCGwECAQABAgEbATcBJAEVARsBFQENAUYDCAJGAwwBCwEJAgQBWQFfAQkBYQFBATcBJgFGAQECQwELAQEEUwFGARUBDAVGAwgBRgQIAUYDFQEIBxsBYAENAVYBOwE/AUQBHgUIAgwBYAELAV8BUwIBAWEBUgE6AQ4BGQFIAUYBAQFiASYBOAMBAlkBOAFTAUYBOAEIAUYECAFGAggBRgIIA0YKGwFgAUQBJAFMAQ0BRgEVAggBFQEIAQwBXAEVAVsCOAMBAQQBVAEBAhkBRgFTAUsBRwFVARUBUwEFAToBWQEEAQsBOgE4AQgHRgMIAkYDCAobARUBOwFWAxUBRgEIARUBOAEMATgCFQFgAVsBCAEbARICGQEIAhkBGgE1AUIBOgEoAQUBIQE6AVQBBAFfAjgBUwEIARUBRgEVAkYBCAZGAhUBRgQVAhsBFQQbBhUBCAEVATgBDAFZA1QBBQFGARoBWwELARkBRgIZATwBDgE8AhkDSAFBASYEQwFZAjgBUwFbAlMBRgEIA0YDCAZGAhUBGwEVARsGFQEIAVMDOAFfAQUBLgJIATkBGQEaAUIJGQEdAQ4BIQJUATUCYwFaAUMCUwJbDkYNFQNGAVMBYgNjAVEBDgYZ"),
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
};