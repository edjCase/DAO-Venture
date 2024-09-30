import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "faerie_market",
    name: "Faerie Market",
    description: "You stumble upon a hidden faerie market, where glittering stalls float mid-air and the shopkeepers have an unsettling number of teeth in their smiles.",
    location: {
        zoneIds: ["enchanted_forest"],
    },
    category: { "store": null },
    image: decodeBase64ToImage("ZBYgNCIlOTQ4OisxQjYiKTklKkUyNDs7O0ouJ0E6OlI7M0VAP1xHPlZEPko5OWdKPFpNQ3dcPEhDQjlAS0FBSEpJSJFnPsqNTm5WQExMTVRNS3ZlaSwwTWNEOnJKNnNSO2tSTYRiRDc2RFxEPF4/NMKdeGZNRUM1QT0qMm1RPIBcPUkxNjs9SP3kwYhTQFVDS0lDSLdvRX1bSKhlSIFXPlE0OUs8RFA7QVU7QWpEQ189M1c8OndKQ4BWSGU/NmhANEU9QnROO0Q4O1Q7NWNCOXNLPFA+PmFDP5hrRk87ObxrSltHQVJFQU0+Qk5CQZhtUZltT3VLQGJLQnZXQ2tQQ1I9PFZHQmZIP0EnJ2RFPU07PVFDQkwuJl5EP1lKRG5OR3RXRjkfKldGRVhLSgsAKAECAAEBAQACAQoADwEBAiQBAQADAQYABQECAgEBDQIGAxIBCgIBBAQBBAADAQEFBAIBBgECAwYCAgIHAgIBBwEDAQcBAgsDBQEBAwQCAQcDAgEIAQYEAgEGAgIEAQEAAwEBAgIBAgIDAQEJAQoBAgEGAwkCBwEKAQcBAgEHAQsBDAEHDQMBBwECAQcDCQEHAQICCQEKAQIDAQEHAQEBAggBAgICAQICAwEBBwICAQcBCgEHAQoBAgEHAQoBDQEOAQ8BEAERARIGEwUDAQIBCQECAQkBBwEJAQoBCQECAgcBAgEKAQcBAwIBAQkBAQECBgECAAECBAEBAgIBAgIBBwICAQcBAgELAQIBBwEUARUBFgEXARgCEQEQBxMDAwQCAQkBCgIJBAIBCgEHAQMKAQIAAwEBAgYBAQIBBwICAQkBCgIJAQsBGQEaARYBFwIRARkBEQQZARsBGQITARwDAwMHAQoBBwECBAMBCQECEAEBAgYBAwICCQEKAR0BHgEfAhkBGgIgASEFGQMbAxMBIgETASIBBwIDAQIDAwEBAQMBAQEDBQEBAgIBAgIMAQEDAgIBCQECAQcBCgEjAR4CFwEQCRkEGwEZAhMBIgETASIHAwEBAQMBAQEDAwEDAgEBAQICAQICAgEBAgcBAQMCAgIJAQoBJAELAR8CFwEQBhkEGwMlAhkBEwEiARMBHAEDASILAwICAQYBCQICAwEBAgIBAgIFAQEDAgIBCQEHAwoBCQEQAiYGGQQbBCUBGwEZAxMCIgEnASIIAwECAQMCAgIGAQIBBwQCAQMCAQICAwEBAwICAQcCCgEJAQcBCQEoARIBFAEVBBkGGwQlARsBGQETASICEwEpASoBDwEiAgMDJwEDAgIBBwEJAQIBKwYCAQcBAgEBBAIBAQMCAQkBCgEJAQcDAgEoAQcBLAITAxkEGwMlAi0BJQEbARkCFAITASoBFwEqARQBLAEiAS4BFgEeASIBAgIJAgIBKwYCAQkEAgIJAQIBBwICAgYBAgEKAwIBKAEHASwCEwMZAxsDJQItASUCGwIZAS8BMAEUARgBMQEpARQCLAEuARcBLgEsASIBBwICAQMBKwMDAQIBBwEJBgIBCgECAQkCAgEGAgIBCgECAgMBKAEnASICEwMZAhsCJQQtAhsCGQEyATMBNAEwARQBFQEUARMCIgENASoBIwEiBAMBJwE1ASgBAwICAQcBAgEKAQkDAgEDAgIBCQEHAwIBAwECAwMBJwE2ASwDEwIZAhsBJQMtASUDGwIZASEBJQEWARQEEwYiBAMBJwEoAQEBAwICAQcBCQEKAgIBCQYCBQMBAQEDASgDJwEiAhMDGQgbAxkBGgEhARABEwQcCgMBIgEoAQMBAQIDAQIBCQEKAQkBAgEJAQoFAgEDBAEBAwEoASIDJwEiAxMDGQUbAxkGEwEcDQMCJwIDAgEBAwECAgkCAgEKAQkCAgEGAgMEAQEDASgBIgInAjYBJwQTBxkHEwIcDAMBIgInAiICAQEDAgoEAgEJAgIBBgEDAwEBAwIoAycBNgIvATYBLAQTBRkFEwEiDwMBIgUnASICAwIJAQIBBwUCAQ4BAwEBAgMCKAQnATYDLwE2ATABFAQTARkFExEDASICJwE2AycBIgMDAQICCQECAQkDAgEKAgMCKAUnATcBOAM5Ay8BFAgTARwGAwYCAQMBAgEDASIBJwE3AzgEJwIiAgMBAgEHBQIBOgQoAisDNQE4ATsBOQE8AT0CPAIvATYBLAITAiwCIgQDCwIBIgEnAjgBLwQ4BScBIgEDAwIBCQECAQcBOgIoAQYCKwI1AT4BOgE7AToBPwE8AS4BMwEuAjkBLwFAASwBEwEiAScCIgoCAQcBAgIHAScCOAI5ATwDOQM4ATcEJwMCAQcCAgE6ASgBBgErATUBJAI/Ax4BPwFBATQBLgFBAS4BPAI5ATgBCwEsAQcBDgMHCAIDBwFCAScBOAE5ATwELgI8AjkEOAE1AScCAgEJAQYCAgFDAQYBKwFDASQBRAEeAR8DNAEWAS4CNAEWATQBPAE0AUUBDwE4AgsBRgEJAgcBAgcHAgkBQgE1AUcBPAEuBTMDLgE8AjkBPAE5AjgBBwECAQcBBgECAQMBQgFHAQoBIwIPATQBKgE0ARYBSAEtATMBSAEWARcBLgFBATQBQQEeASQBEgELATsCCwEJAgcGCQILAUkBOAE8AS4BMwFKAUgCMwFKAjMBSgIuATwBLgEzATwBOQEJAQcBCQECARwBEwEZARsBIAFLASoBHwEqARYBKgFIATEBFwExASEBSAEWAR8BNAExARYBHgEjARIBNgEvAwsICQFJAUwBJAFFAS4DMwFKATMBSgEXATEBFwIxAUoCMwFKAS4BSAEGAQICAwEcARMBGQMbASABKQEqAkgBMwMXAhYBLgEqARYBEQEPAR0BDAFNATcBLwE2BgsDCQEOAg0BHQEfATQBMQFIBRcBLQEXATEDFwExAUoCMQECAQMDHAITBRsBGAEhARYBMQEXAS0BFwExATQBLgFIATMBDwEdAQwBDQIvATkBLwE3AU4CCwEOAwsBDgFJAQ0BDwEpASEBJQExAxcBLQYXAS0DFwEtATMBAwQcAhMBGQMbASUBTwEyAUgBFgExARcBMQFIAhYCFwEPAgwBRwI5ATwBOQEvATgDRgENAkkBCwFJAQ0BDwEpAkgBMQFIATECFwExAhcBMQQXAzEBMwEDBBwCEwEZAxsDJQFQAhYCIQEWASoBFgEpARYBIwIMAVEBPQEuATMBLgE8ATkBRwENAQwBFgENA0YBDQFSARgCUAExARYBSAExARcBSAFQATECSAExAkgBIQJIASEFHAITAhkDGwIlAU8BUwERASEBKgIWATQBDwINAR0BRQEuAUgBMwFKATMCLgE8ATkBDAINAUkBRgFOAQ0BDwEpAUgBJQFIASEBMwYhATIBIQIqAVMCMgFUBhwCEwIZAxsBJQFPARgBDwEpASoBSAEWATQBDwFVAQ0BDwE0ATMCSgEXAUoBMwEuATwBOQEjAQ0BSQFGAU4BTAFWAgwBKQERATEBHwFIAzIBIQEyAVMBKQEYAlMBVAFXAQ8BUgEBAygBBAEoAgYBSQEJAQ4BOwEIATQBTwEhAQwBDwEqAh8BQQENAVUBDQEdAS4BJQExARcCMQIuAh4BHQENAkYBTAFOAUwBDQEMASkBDwIMARYCUwEyAhgBKQJUAQ8DDAJLAQUBBAEGAUMBCgEeASoBHwEuAT0BPAFYAh4BJAIjAQwBKQIdAR4DSQEjAQ8CNAEqATQBQQEeAUEBJAEjAQ0BSQEOAQsBEgELARkBRgEMASMBDAENAQwBIQRUAQ8BVwEPA1IBDAJLAVIBBQE6AQoBNAExARcBSAEhATwBSgEuAVkBCgIkAyMDHQEPAUYCSQENAT8CDwEfAS4BHgE/ATsCQwFJAQ4BCwFaAU4BEgEvAUYBDQFGAUkBVQENAUgBLgFSARgBMQIdAVkBUwEXAS4BMQEXATwBSgEEASQBNAEhAUgDMQEWAT0BHQEPAgoCEQIjAQ8CLgE/AU8BSQEOAUkBHgFEASkBDwFEASQBPwFJATsBQwFCAgkBWgENARYBKQFVAQ0CSQFGAVUBNAIWAUoBFwIdAS4BFwExAS4CFwEuAVEBBQIkAR0BKQFTAR8BNAIpAQ8BRAEkAR0BDwEhAR4BPwIWAR4BPwEyAQ4BCwFJAR0BDwEdAyMBPwFJAjsBQgEJAUIBWgE8AS4BDwFJAVUCDgJaAR4BVwEPAjQCLgFBAh4CQQFFAQ8BRAEFAiQBLgExAR8BKgEhAUgBUwEqAToBHQERASkBNAEpAh4BDwEkAT8BEAIJAQ4BRAEkAyMBJAEeATsCSQEJAUIBCQFaAjQBQQE7Ag4BQgIOAT8BWwJOAUYBIwENAiMBDAEjAUUBPQE8ATMBBQFDAQ8BMwEWATMBMQEuAUgBPQEWAQ8BIwIfAS4BDwEpAiQBHQE6AQoBDgIJASQBKQEuAUUCRAFBAUQBDgFCAwkBQgFEASMCOwNCAQkBDgE/AVoBTQFOAUYBDwEeAjMBLgJFAi4BHgEFATsBMgIpAlMBHwIpASMBVAEkAUUBLgEWASQBNAEkARYBNAE/AUEBCgEGAUICJAE0AS4BDwFEAR4BQwErAQYCBwEJAUIBVQM7BUIBPwEOATYDWgEeAy4BUQEeAUUBDwFEAQUBIwEyAR8BGAFTASEBUwEpAU8BSgE6AT4BQQEuATMBHgE0AR4BMwEWAR4BIQEkAQ4BQgFDAToBHgM/AR4BPwFDAQYECQInAUIBBgVCAT8BDgFaAU8BRgEOAloDRgFVASMBRQFXASgBWQFDARsBHwFTASEBMwE0Ai4BPwFBAT4BHgJBAzQBQQE/AUgBHgEKASgBKwE6AT4BHgFBAR4BOgFcAQYCCQJCAQkBDgI1ASsBQgEJA0IBPwFEARcBTwEWARcBSQFaAT0CVQJFAUEBSAEoAR0BKQFPAS4BNAEeAUEBHgE8ATMBLgFcAUECLgQWAi4BHgFDAygHBQEoAQYBDgFdATgBVwI6AT8BPAQGAToBPwEzAUoBMQE0ARcBFgFVASEBIwEuAUEBIQE0ATEBBQEPAToBPwEeAy4CMwEuARYBQQEeBggCWAUoAgQDBQEEAQUBKAEGAUMBJAEuAT8BHgE6AR4BPwMGASsBPgEeAjMCFwEzARcBUQFKAi4BFgIzARYBBAEFAQQEBQFYAgUBXAIECQUFKAEEAQUBBAQFAigBKwFDAT4BHgFBAT8BHgFDAigBBgEeAy4BMwExATMCMQEWARcBSAEXAS4BFwEeAT8DBAIFA1gCBQFcAQUBBAUFAQQDBRQoAQUBKAEHASgBBgE1AR4CMwIxAUoGFwFKAy4CBAEeATEBCAVYAVwBWAE1CAUBWAMoAUIDCQFCAycCBgFCAgYBKAEGAigBBQEoBQYCWAFcAToDPwIeAT8BOgFcAQgEBAEuATEBMwEIAVwBMQEIAVgBOgEzAUMBOgEKAwUCCgFYAT4BOgUOAUICDgZCAQYEKAEFASgBCQIGASgBBREEAR4BMQEXAjoBFwEWAR4BPwExAT8COgMFAT8BNAFDAT8BHgFJAVoDRgFVAVsBRgJbAQ0BTAFOAUYBWgEOB0ICBgEFEAQBWAE6ATQBMwE/ATEBMwE6ATQCOgExAQYEBQE6AS4BPwErATsBVQFWA0sIUgNLBA0DRgElAUoBMwEuATkOBAEFAQQBWAEKAToBLgI6AQoBCAIeAUIDCQIGAlUBDQFLAV4BUgJUAV8KYAFfAVQDJgJSAUsBLgFKATMBLgE6CwQBBQEIAQAKBAEKAU4BTQJOAVsBTAFWAUsBUgEmAl8BYAUyCCEDMgNgAV8BJgE6AmEBBAFYBQQBPwI0AUECBAEoAQgBAAoEAQoCTAJWAV4BUgEmAiABYAMyAyECTwlQAU8CIQMyAWABDwEIAgQBBQUEAVwBHgEqAR4BWAEEAggBAAoEAQgBTAFWAV4CUgEmASACYAIyAiEGUAMxATMGUAFPAiECMgFgAVwBBQEEAQUFBAEIAlgCBAEDAQQBBQEACgQBKwFOAVsBXgEQASYDIAFgAzIBIQJPAVABTwtQAU8BSAIhATIBYAFfAVwBCAEGAQQBKAICAgMBCAIFAgQDAwIACQQBBgFOAVsBYgFeAhABJgIgAWADMgEhCE8CUARPASEBMgFTAWABVAEmAUsBCAFaAkIBJwQiBQQCAwEBBQAFBAEoAScBQAIwAi8DYwEmAyABYAQyCCEGMgMgAV4BYgFbAjABFAIsAiIBBQQEAQMJAQMDAiIBLAIUAjADFQRjBSABYAEyAmACMgJgBiABJgJjAS8CMAFAAiwDIgMDDAEFAwMiAywCFAEwARUCGQIaBGMIIAVjAhoBGQIwAhQBLAIiBgMOAQcDAiIDLAETBBQBMA8ZAjACFAEsARMBLAEiARwHAxIBBgMGHAkTARQKEwIiBAMBHAMDCAEDAA=="),
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
};