import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "goblin_raiding_party",
    name: "Goblin Raiding Party",
    description: "You stumble upon a group of goblins attacking a majestic unicorn. The air crackles with magic and desperation.",
    location: {
        zoneIds: ["enchanted_forest", "ancient_ruins", "scorching_desert"],
    },
    category: { combat: { normal: null } },
    image: decodeBase64ToImage("ZHd9KYCILXiAL2NtJlVgNElPMD5YS0pWLmdrMVJcMkRJLFRdMl1nMjszJTU8K1VWLS0zKUFFLU5RLUBPPk1cPm58ODg1LklKL05SMCgtLSwmIneAMkdGKysyKC8tIiwhIz5GMDtDKmJsRG2AR0NBLzZBNkNJLzQ9MmFxO1dqPi0zNB8fHT9JO05ePj9HLkZUOEROOERROycdHklWO0NWO0tVOTg+Nj5DM19nNTg+NE9YNFBFLj1BNVFONmBIOGNhPVVaPUdRNVZkPlpmOl1LOEZFLWZwOVZjN0ZONURNPURHPEVDN1JELElPOFJaOUlTMlRXL0JMNFJcN19pNUtSM1hnNV9fOUJCI0hPNFtjNlZdO2VtPFZZM1ZSMU9TMlhkNVlgNlRdN1NXNE9TNgQAFAECAgIAAwMBBAEFBAYDBwEAAQIEAQECEQEEAAEBAQABCAEDDwEBAAECAggEAAEHAQkEBgEKAQcBCwECDQEBAAIBAQgGAQEAAQUBCAECAQEBAgEMAQ0BDgENAwEBDwEBAQIHAQEAAxABCgERAgABEgELAQUCEwEGARQBCQEVAQABAwEBAQABDAIAAQIBAQECAg8CAQEPAQgBFgEXARgCAQEAAgECGQEaARsBAgEcARoBDQEZARABHQIBAQADEAIBARABHQIBAQIEEAEOARAEBwEGARMBBgEUAQgBAAECAgABAwIKAQUBCwEBAQICDAEAAQMBEAEdARoCEAECAgEBHgECAR8BGgEfARoBAgEeARoBDQQQAgEEEAEMAxABHQUQAQ4CEAEFAQcBIAQGAgcBDAIHAiEBDgEiASMBAgEhAg4BCwUQAh0BEgEaAhkEHwIZARoBJAMQARkCHQ0QAw4BJQEhASYBEwMGASYEBwEhASUCJwEjASgBAAEpAScBDgIQASoBEAIZARABHQIZARoBGQQfARkBKwEaAR8BEAEdAxkPEAEOASUBLAMTBAYBLQEmAQcBLgEvATABMQUjAQ4CJwEQAR0CEAEZARoBEAQZBB8BGQEyAQ0CHQMZAyoCEAEZAicBGQEqBRADJQEsBBMCBgMtARQBIgEUATMBNAYjASkBJQEpAhkBEAEGAScBGgEZARoBGQcaBRkCKgEnAioCGQEqARkBKgInASoBEwEsARACJQIsARMEBgItBCkBMAI0ByMCKQEGARkBEAIGAR8DGgEZARoCGQIaARkBKgIZASoBGQMnASoEGQIlAScCJQEsARMBLAElAywCEwQGAi0BKQEiASkBIwEnATQBMQEiBSMBIgIpASoBEAIGARkBGgIeAhoCGQEaARkBKgMZASUCKgInAxkHJQMTASwBBgMTBQYDKQEiAiMBFAI0ATMBFAIjASkBKgEtASkCBgEqASwCBgEaAg0BHgEZAx4BGgEqAhkBEAEnASoCJQMZAScCLAETASwDEwEGAhMBJQIsARMGBgMpBSMBLAEzATQCIwEOATUBLQIGASkBNgEqAgYBGgMNARkBHgENAR4BGQEqARkBEAEZAioBJQQZBCUCLAITAQYDEwIsARMHBgEtByMBNwE0ASIBHQEFARUBGwEDASkCBgEqASUBJwEZAQ0BJAENARkBDQEkAQ0BGQIqARkBEAEqAiUDGQE4ASUBLAIlAxMFBgMTBwYBKQgjASwBHQEHAQgBAQEbARUBOQMGARkBKgEZARYCJAEZAQ0BJAENARoBKgEQAhkBKgIlAhkBDAEBASwDJQITBgYCEwEsBwYJIwEQAToFAQEMAQUDBgEqARkBDQIkARoBDQE7ASQBDQMqARkDJQEZAQ4CAQEPASwBJQMTAQYBEwUGASwBEwcGCSMBPAEVARsEAQEbASEDBgEZAQYBGQIkARkBDQE7AT0BJAIqARkBKgIlARkBIQEbAgEBAwEQBBMBBgETBgYCLAYGAS0DIwE+AT8BIgFAARoBQQYBAUIBQwEzAUQBAQEbAQYBEAEkATsBGQEWATsBPQFFAxABKgElASoBJgFGBAEBDAEGAxMBBgETBgYBJQETAwYBEwIGAS0CKQIjAj8BAQEWAUcEAQEjAQEBSAFGAgEBPwEWAQYBHgEkATsBGQEWAUkBLAFKAxkCKgEgARUFAQEIAQ4BBgITAQYBEwcGASwBEwIGASwBBgItAQYBLQEpAiMBSwE/AUwBRwEQARoBIwFDAkwBKQFIAT8BGwEWAgYBGgI7ARkBFgETASwBTQIqAxkBBAEVBgEBDAEGAhMBBgETBwYCEwIGASwFBgIpAiMBPgFAATkBLwE5AUcBLwEOASABIwEdAUwBRAMGASICJAEZARYBIwETAS0BPgEBARQBMwE2ASgHAQEFARABEwsGASwCBgETBQYBKQEiASkCIgFLATUCAQE/ARsCAQFHATkBNgEGARkBJQEjAyQBGQIjAT8CBgEbAgEBOgFOBwEBTwEoASMCAQEjCAYBJQIGARMFBgQpASIBKwERASABKAMBAUcBJwERAQsBUAEIATMBGgEWASQBFgEZARYBIwEsAhMBEAI/ARYBNQFCASADAQEOASMBUQIBAT8BEwEGARMHBgElAgYBEwgGASIBGQEWAREBEAEaAScBNQEQAQ4BEAEIAQMBAAEMAhkBEAIkARkBEAEjARkCEwE5AT8BRAFSASMBTAE+ARoBIgEfAT4BUwEQAT8BGwFMAhMCBgITAwYBEwElAgYBLAkGAR8BIQEFAR0CEAEaAScBOQEWARICGwEAATkBGQEQAiQBGQEQASMBEAEnARoBJAENARkBKwFSAgEBPwQBAQ0BTAFLBxMCBgETASwBJQMTCQYBDgEhAQoBIQI8AT8BLwEVAQ0BDwEDAxUCAQEVARYBGQEQASMBGQEnAQ0CDwEkARABKwEoBAEBKAErAhwBGgcTAQYDEwElASwBJQE3AVQBEAcGASsCFgEhASgBIwEUARsBAQEeASQBDgErAScBFgEoAQEBJAEWARkBEAFLARYBGgEcAQMBAAEPAQcBEAErATUBKAFTASABGgEQARIBDAEPAQ0JEwEsAScCOQEIAQEBQwETBwYBEwEWARABKAEVAUIBGwIBARYBHQEyAR8BFgEbAUYBEAEWARkCRAEaATEBAwEPAQMBHAFVAQ4BHQErAU8BDgEZAR0BIQELAQMBHAEGCRMDLAEJAQACAQE3BwYBJwEWAR8BNwFHAU8BNQJTAS4BFgIyAUwBPwE7AhABHwE/AkQBGQFFAQgBAwENAVUBUgEOAR4DEAEmAQ4CAwEeAhMCLAITAiwCEwEsARYBGAICAgEBCAEQBgYBJQEgARkBIQEHAQsBBAFVAQkBBQEOATIBKwE7AVYBDQEQASUBRAEaATsBDQEZASoBMgErAR4BVQEBAUcBGgFXARwBUwEHAg0BDwEkBBMDLAETASwCEwERAQQBAgQBAQwBHgIWAwYBKQEQARYBIQEmAQkBUwEHAQQBIQEWATIBHgFEATsCGQElASQCDQFKARYBLQE5ARoBMgE5AwEBUQFEARIBDAErARoBEAEGAxMFLAETASwBGQEHASgBGwUBAQUBMgEaAwYBUgEqARABDgE6AQUBBwEJAQUBHgE7AUsBPQE/ASQCGQElAhYBOwE1ATwBIQMrARABUgEoARsBKAEmAQ0BHAEaAQ4BOQEGARMILAETATYDFQUBAUMCRgEwARMBBgE0ARYBMgENASQBPwEkAT8BHgENATsBGwIVARoCGQElAScBHgENATcBSAENAisBGgEnAU8DAQEoAToCKwEOAUEBJQETAiwBEwEsARMCIwEiAUIBMQFHARsGAQE1AT8BFQIBAT8BOQEfARoBHwENAj4BTAENAR8BRAEVAQgBDAENARkBKgInARoBOwIWATICKwEyARABQQFDARUBUwEJAS4BHwErAQ4BRwEZAiUBLAITASwCEwE/AQEBPgEgBwEBUQEbAQECGwEAATABOwENARoBHwI+AQ0BGgENASQBHgEkATsBGgEQAicBDgENAUQBDQErAR8CMgEaAQ0BWAEoAUMCWQE7AQ0BHgEQAUEBWgEQAkQFEwEeATsBTAEsASgBIwEBARsBQwEOASABMgE+AT8BCAICAjsDDQIaAR8BDQFMAR4BRQEeAR8BMgEqAicBEAFEARsBFQEjARoDMgINASQBWwE/AUwCDQEfATkBHgEkAkQBDQETAywBEAEeAR8BPgEeATMBGQEOASgBEAE8AUcBFgE+AR4BDwEAAQMBRwEeAUQCDQFMARwCTAEaASEBGgFFAQ0BGgEqAScBKgEsASQBXAE/AQ0CPgEaAQ0BHgINAT8BDQEaATIBGgEfARoBDgENAUQBTAErAhMCLAEyAR4BDwFXAQ0CAQFVBAEBKwEeAVcCDwExASYBGwE7AQ0CRAFdAUQBHgFIAgEBHwINAR8DJQE7AVYBOwEyATsBTAEaAQ0DMgFbASMBDQEeARIBVwEcAR8BGgIkAQYDEwEsARABDAEPAg0BFgEoARUCAQFDAR8BGgIcARIBGgEnASYBPwI3AR8BDQFEAR4BUQFDAgEBTgEfAQ0BHgIlAScBEAEWASQBGQEyAR4BMgENARoBXQE7ARoBHwESARwBHgFEAV0BDQElARUBRgFEBBMBPANXAQ0BHwErAVEBQgFRAR8BGgEeAUwCVwEnATIBJgE/AUEBOQIaAkwBNwFCAgEBLwEnAR8BDQIOAiUBHgENATIBHwEyAQ0BHwEcAQ0BVgQIAVcBHgFXAVYBGgIEAT0EEwEjAQEBXgEeAQ0BGgMrARABHQEOARoBTAFXATIBJwEeAkQBEAEWARABMgENAUwBEAE1AgEBKAEaARABGgEeAicBNwEeASQBKwEyAhoBKQFdARwBDQIIAVcBCAENASMBGgFWAUwBBAEWAVwBJAITAQEBRgFIAisCMgEQAQ4BEAEgAiEBHgEaAjIBJwEyAkQBPAEWARkBLAE8ASQBKgEQARUBAQFDARoBJwEQARoDLAEWASQBKwEyATwBFQEoA0QBDQFdAQ0BVgFdARsBKAEfAVEBQgErATsCEwEVAQMBHAMrAjIBGgIdAQUCDgEeAR8BMgErARABOQE9AUQCEAEZAicBKgEQARoBWgFIATMBUQEQATcCIAI3ARYBDQIyASgBAQEVAkQBXQEsARYBMgEkASADAQE8ARYBQAE9ARMBJwE4AQEBPwEeASsBMgIfAjIBGgMfARoBHwEyAR4CFQIbARQCGQQqATICEAE3ARoBEAEwAlECIAEWAR4BJQEyASMBAQEoAUsBNwFLARMBMAFRATIBIAEEAgEBFgEsAVECLAEfATsBRAEjAUQBHgIyARoCHwENAh4BDQEyAR4BDQEaAT8BGgFWAT8BMQE8ASUBEAEqASsCKgIZAR4BGgIQAVEBSAEgASECEAElATcCAQEtBCwCMQFRATwBVAEBASMBGgEsATcDUQEkAj8BDQIyAR8DMgEjAQ0BHwEyATsBTAEeATIBOwEaAT0BVgEaARABGQEQAR0CGQE5ASoCHgEaAhABWAEFAiACEAEaATcBAQEbASgCOQIgBFEBTgEbAQEBEAVRARoBOwFWARUBAQMjASIBNgEqATsBJAENAUwBDwE4Ag0BTQFLASQEEAIdAhkBEAIeARoCEAEmAU8CNwIQARkBOQEjAVoBMAEZATcDIANRATkBOgEoATEBNwFRAS8CQQEWATgBCAEBAT4CHwEeAQ0DTAFEARoBOgIBAUkBMgEfBRABHQIQAR0BEAEdAg0BHgEQATcCTwInAhACGQE5ATcBHwIQAiADUQE5ARYBUQEmATABKwJPAkEBGgFEAV0BRgEkAT4BKgE3AUsBDQEkAUwBXQEeARUCAQFCATAHEAUdATsBXQE9ATwCQQFPAUgBUQE8ARACGQEaARkGEAInATICFgE9ATIBLwJPAVQBLgEgARYBJAFWAkQCIwIsAR4BJAFMAR0BWgEJAQEBWAErAxABIAEmAUEBWAE1BB0BOwI4AT0BJgE6AQkBUQEnAhABHQIaChADGgIOAk8BNQEuASABFgEQATIBHwEWARAEUQE3ASYBPAE5AUEBQwEgAVoCEAEdAToBTwFDAUcBXwEEAVIBWAEZASQBCAEVAT8BHwEJAToBNwE1ATcBEAEdARYBDQEZCRABGgINAw4GIAEQAR8BGQMQAQ4BJwEwAVEBGgE3AR4BUQFEARYBKwEgAV8CDAZfAQQBJAFWAVsBDQFgAQsBCQEOAlIBFAE7AT0BDQoQARYBJAENAQ4BEAEOARABIAIhAiABNwMQAx0CEAFRARABMgENAiQBHwEQAU8BWQIMATgBKAQMAV8BOwEcAVYBDQEJAVMBCwE3AVQBBAE7AUYBPwENAUgBNQFSAjoEEAEdASQBVgFdAxABNQFBBCABHQEQAh0BEAUdARABHQMaAhABCQE4AwwBVQFfAQwDFQFGAQwBJAEhAToBGAFbAVQBJgFgATsBWwE/AQ0CYAFZAl8BUQEhARABGQEQARYBFQFGARYBEAE3ATgBDAMhATkMHQEaAQ0BGgIQBwwCCwMVAUYBBAE6AVEBTwFHAToBVAE6ASQBFQEbATsBBAFZAV8CDAELAVIBOgEWAR0BHgFWARsBVgFEA1MBOAFTAVEEHQEwAh0BOQQdATIBDQFEATsBEAEuAUYBFQMMAhUBWQEEAQsBXgELA18BVAFhAToCJgE6AQQBOAEVAQQBYAEEAWABGwEMBAgBRgEaAT0BFQE4AVsBXQJTBQgBRgIIAVMBOAFZARAEHQE7AQgBVgE3AQsBCAFGAVMBCAJGAQgCRgFfAVIBVAEEAUcBXwE6AWEBOgEgAUgBOgELAQ0BCwIEAQkBBAEbAVMDRgEIAUYBYAEeATsBRAEBAQ0BUwEIAVMDCAJGAQgDRgIIAVwBXgE6AR0BDQEbARUBOAFGAwgBRgEVAVkDDAFZAUMBCQELAQQBXwFSAToBOQFNATcBJgELAVABKAELAWABCwFTAV8BUwEMAQgFRgEVATsBWwEXAUYDCAFgAhUBGwEVAggCGwECAQABAgEbATcBJAEVARsBFQENAUYDCAJGAwwBCwEJAgQBWQFfAQkBYQFBATcBJgFGAQECQwELAQEEUwFGARUBDAVGAwgBRgQIAUYDFQEIBxsBYAENAVYBOwE/AUQBHgUIAgwBYAELAV8BUwIBAWEBUgE6AQ4BGQFIAUYBAQFiASYBOAMBAlkBOAFTAUYBOAEIAUYECAFGAggBRgIIA0YKGwFgAUQBJAFMAQ0BRgEVAggBFQEIAQwBXAEVAVsCOAMBAQQBVAEBAhkBRgFTAUsBRwFVARUBUwEFAToBWQEEAQsBOgE4AQgHRgMIAkYDCAobARUBOwFWAxUBRgEIARUBOAEMATgCFQFgAVsBCAEbARICGQEIAhkBGgE1AUIBOgEoAQUBIQE6AVQBBAFfAjgBUwEIARUBRgEVAkYBCAZGAhUBRgQVAhsBFQQbBhUBCAEVATgBDAFZA1QBBQFGARoBWwELARkBRgIZATwBDgE8AhkDSAFBASYEQwFZAjgBUwFbAlMBRgEIA0YDCAZGAhUBGwEVARsGFQEIAVMDOAFfAQUBLgJIATkBGQEaAUIJGQEdAQ4BIQJUATUCYwFaAUMCUwJbDkYNFQNGAVMBYgNjAVEBDgYZ"),
    paths: [
        {
            id: "start",
            description: "The goblins are closing in on the unicorn, their crude weapons raised. What do you do?",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "attack_goblins",
                            description: "Charge in to defend the unicorn. Time to be a hero!",
                            requirement: [],
                            effects: [],
                            nextPath: { single: "goblin_combat" }
                        },
                        {
                            id: "intimidate_goblins",
                            description: "Attempt to scare off the goblins with a show of strength.",
                            requirement: [{ attribute: { attribute: { strength: null }, value: 4n } }],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.3, kind: { attributeScaled: { strength: null } } },
                                        description: "Your impressive display sends the goblins fleeing.",
                                        effects: [],
                                        pathId: ["unicorn_freed"]
                                    },
                                    {
                                        weight: { value: 0.7, kind: { raw: null } },
                                        description: "The goblins are unimpressed by your display. They turn their attention to you, weapons ready.",
                                        effects: [],
                                        pathId: ["goblin_combat"]
                                    }
                                ]
                            }
                        },
                        {
                            id: "join_goblins",
                            description: "Decide to join the goblins in their attack. That unicorn horn could be valuable...",
                            requirement: [],
                            effects: [],
                            nextPath: { single: "unicorn_combat" }
                        },
                        {
                            id: "ignore",
                            description: "Choose not to get involved.",
                            requirement: [],
                            effects: [],
                            nextPath: { none: null }
                        }
                    ]
                }
            }
        },
        {
            id: "goblin_combat",
            description: "You engage the goblins in fierce combat to protect the unicorn!",
            kind: {
                combat: {
                    creatures: [{ id: "goblin" }, { id: "goblin" }, { id: "goblin" }],
                    nextPath: { single: "unicorn_freed" }
                }
            }
        },
        {
            id: "unicorn_combat",
            description: "You and the goblins surround the majestic unicorn, weapons drawn.",
            kind: {
                combat: {
                    creatures: [{ id: "unicorn" }],
                    nextPath: { single: "post_unicorn_combat" }
                }
            }
        },
        {
            id: "post_unicorn_combat",
            description: "You've defeated the unicorn, but the goblins are still here, eyeing the fallen creature's horn.",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "kill_goblins",
                            description: "Turn on the goblins and claim the unicorn horn for yourself.",
                            requirement: [],
                            effects: [],
                            nextPath: { single: "goblin_betrayal_combat" }
                        },
                        {
                            id: "buy_horn",
                            description: "Attempt to purchase the unicorn horn from the goblins.",
                            requirement: [{ gold: 50n }],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.6, kind: { attributeScaled: { charisma: null } } },
                                        description: "Your negotiation skills impress the goblins. They agree to sell you the horn.",
                                        effects: [
                                            { removeGold: { raw: 50n } },
                                            { addItemWithTags: ["unicorn_horn"] }
                                        ],
                                        pathId: []
                                    },
                                    {
                                        weight: { value: 0.4, kind: { raw: null } },
                                        description: "The goblins laugh at your offer and refuse to sell. They take the horn and leave.",
                                        effects: [],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "leave_empty_handed",
                            description: "Walk away from the whole situation, leaving the horn to the goblins.",
                            requirement: [],
                            effects: [],
                            nextPath: { none: null }
                        }
                    ]
                }
            }
        },
        {
            id: "goblin_betrayal_combat",
            description: "The goblins bare their teeth, ready to fight for the unicorn horn!",
            kind: {
                combat: {
                    creatures: [{ id: "goblin" }, { id: "goblin" }, { id: "goblin" }],
                    nextPath: { single: "dead_unicorn" }
                }
            }
        },
        {
            id: "unicorn_freed",
            description: "With the goblins gone, the grateful unicorn approaches you.",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "accept_gift",
                            description: "Accept a gift from the unicorn.",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.5, kind: { raw: null } },
                                        description: "The unicorn grants you a blessing, filling you with magical energy.",
                                        effects: [{ heal: { raw: 20n } }],
                                        pathId: []
                                    },
                                    {
                                        weight: { value: 0.5, kind: { raw: null } },
                                        description: "The unicorn presents you with an item to cleanse evil along your journey.",
                                        effects: [{ addItemWithTags: ["cleansing"] }],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "attack_unicorn",
                            description: "Betray the unicorn and attempt to take its horn.",
                            requirement: [],
                            effects: [],
                            nextPath: { single: "betray_unicorn" }
                        }
                    ]
                }
            }
        },
        {
            id: "betray_unicorn",
            description: "You've betrayed the unicorn and taken its horn.",
            kind: {
                combat: {
                    creatures: [{ id: "unicorn" }],
                    nextPath: { single: "dead_unicorn" }
                }
            }
        },
        {
            id: "dead_unicorn",
            description: "The unicorn has fallen, and you've taken its horn.",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "take_horn",
                            description: "Take the unicorn horn.",
                            requirement: [],
                            effects: [{ addItem: "unicorn_horn" }],
                            nextPath: { none: null }
                        },
                        {
                            id: "drink_blood",
                            description: "Drink the unicorn's blood to rejuvenate yourself.",
                            requirement: [],
                            effects: [{ heal: { raw: 20n } }],
                            nextPath: { none: null }
                        },
                        {
                            id: "leave",
                            description: "Leave the unicorn to rot.",
                            requirement: [],
                            effects: [],
                            nextPath: { none: null }
                        }
                    ]
                }
            }
        }
    ],
    unlockRequirement: { none: null }
};