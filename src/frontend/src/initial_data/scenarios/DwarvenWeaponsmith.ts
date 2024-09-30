import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData =
{
    id: "dwarven_weaponsmith",
    name: "Dwarven Weaponsmith",
    description: "You encounter a surly dwarven weaponsmith, his beard singed and eyebrows smoking. He offers weapon upgrades at prices that could make a dragon weep.",
    location: {
        // zoneIds: ["mystic_caves"], TODO
        common: null
    },
    category: { "store": null },
    image: decodeBase64ToImage("YyIZHSUZGy8gHzciHUEmID4nG1MsGVIrGFQsF04pG00qHVAsH08tHlIuHVYuIXc/I3pBJX9DJl8wHVEpF0IrIzEkIUkuJVg1J0sxJzsnIVMxJV4vGUcxKTsoJjYpJC8gIioiH0YpHV05KGUyGFAzJkkyK04zKz4sKz4nIyUcH5BQI081KUIuKzggGXlCJE01JlQ4L1I4MEg1MEcyLUEwLkw1LVY+MlE4L045MF4+N15AOVA4MFI7M0s1L0U1MTksK2tHOE88OzYpKEIzMj4xME81LTEnJ2hFOFs3LjQpKF1DPGtLQlo6KkkzMlNBO3ZRPlY+P1c/OYRjVl89LlU9N3pTPHZNOoRgRXFOPKdzSnJMO2tOPygZFmhKOIhePY5eSY1gRyIXGCQbJwEAAQEBAgEDAQQBBQEGAQcBCAEJAQoBCwEMAQ0BDgEPARACEQESARMBFAEEAxUBAwEUARYBAwEUARYCFwIYAQQCFgEZARYBGgEbARwBGAEdARQCGQEdAR4CHQEeARsBGQECAh8EIAEAAgEBAgEFAQkBEwEHAQgBCQEhAQoBDAENAhIBIgEjAw8BEAEHAQoCFQECARUDGQEWARgBJAEXASQBGAEWAhQBJQEmASQBGwEcARoCFAIdAycBHgEoAQQBBQECAx8BAgEgAR8BKQEBAQMBBQIJASECAwIhAQoBDAEKAyEBCwEPAREBIwIqARMBIQEDAhUBAgEDAhQCFgEUAhYBKwMcASUBKwETAQUCFAUsAScBLAEnAhQBCwECAh8CAgEgAgEBAwEFARMBLQQCASgBIQEKAxcBIgIXAiICDwEuAREBBAEZAR4BHwEVAQQCFAEZAS8BGAMwATEBHAElARIBLQEoAQIBMgEzBBwBLAI0ASwBHQEUAQkBAgEfAgIBIAEpAQEBFQMCAx8CAgEZAxYBFwEKAyEBEgIjARIBIwEbAQQBGQEeARUBAwEoARQDNQEwATYCMAE3ASsBFgEhAQwBGQE4AzMBMgEzARwBMwE0ASwCJwEdAQQCAgEfASABKQEBCgIBGQEoAhYBDAEkAhYBFAEaAg4BEgEjARIBFgEUARkBAwEdARQBNQElATMBMQMwASsCFAE5AToBOwM8AT0DMgE+ASwBHgEdAT8BHQEeARkBAwICASkBAgMVAh8IAgMUAQUBGQEWAQMBBAEWAQwCCgEJARYBGQEoAR4BFAIsARwCFAEmAjUBPQE4AUABQQE/AzwBOAMzASwDNAEeAUIDFQEDAQIBKQcVBAIBIAICARkBKAEVAicCGQEDAgQBFgELASMBDQEhASgBHQFCASwBNAEzATICPQE7Aj0BOAFAAUEBQgE4ATwBOAE9ATMCNAJDA0QBJwFCARUBHwEVAQIBHAFFAR0BQgMVBEYEHwEgCAIDGQINASMBDQEdAycBMwE+BDgBMgE4AUcBQQFCAUECPAEyASwBNAJDBUQBQgIVAR8BAQIYARoBHQEeAUIBSAIeARUBSQFGARUDHwEgARUDAgEfAwIBKAIUASEBGwESARQCJwFEAkMEOAEyAT0BOgFBAT8BQQJKA0sBPgFBAUMCRAFDAUQBPwEnAT8CQgIDAQ8BHQEeASUCHQFMAhcBGAEsAh4BFQEfAQIBHwECAx8CAgEVARkDFAEbASMBFgEsATQCQwEyATgCPQJNAUoBTgE/AUECSgFHATIBQQFEAUMCRAJDAUQEPwEdAh8BAwJCAR4CFQErARYBFAMwAjYBPAEnBB8CIAECAR8CHgIUARYBDgELARYBNAJDAj4BSwFPAksBQQFQAUMBPgFRAjoBGQJEAj4BOAFSAUcBHgM/AkIDHQFCAx0CUwEVAh0EKAEdAR4BRgQeAVQCFQFGAhUBHgEVAR4BPwE+BEMBPgFKAjoBUQFOAVIBPgFEASwBFAEsAh0BRAE+AUMBHgIoARUBPwFEAz8BHQI/BB0BIgFVARUCHQEoARkBQAFHARUBRgFJAh4CSQE1ARUCSQEeASwDHgFEAT4EQwI+ATgBPQE4BEsCMAE6AUkBHgFSAUoBNAE5ATUBMwEeA0QCPwEDAScBPwFCAx0BIgFWASgDHQEoAVcBVQEVAR4BFQFCAT8CSQEmARUDSQECAUIBRgFJAUQFQwJLAScBSwFKAU4BSwNPAVgBSwFCAUkCFAEZAVkBSwE+AR4CRAEeAT8BRAEeBR0BKAEPAQMBGAQdAlUBHgQ/AUkBHgEmAkICSQEeAj8BQgFEBUMCSgE2AjoBRQFTBVoBHgFCAUsBQQFDAU8BHAE0AUYCRAFGAT8BJwFRAUADRwEdASgBJAInBB0BWgFXAUYCSQI/AkkBRQNJAUIBSgFSAj8GQwE0ASwCHQEsARwCPQIcARgBHAI2AhwBLAEYAhQBOAEVAkQCPwFUATkCVQFWAScBJgEiASwCOQMdAUcBVQFJAz8BMwFJAR4BSAFJAj8BQgFVAVICRAVDAVEBOgE5ATwBTgE4AjMBTwFXAU8BVQJXAVUDTwFVAk8BAgEgBEQBAwEZAhUBAgEfARUBGAEsAiYCHQEoAUcBVgE/ARUBLAEnATMBFQEnAUgESQFXAT8BSQFEBEMBRAE0Bj8BRAE0AUoDPwEnAUABAwMeAVsBXAEpAR8BRAFSAkQBNQEkAh0BGgEeARUBGQIeARUBRgIdAUcBQAEnARUBLAEnASUBFQFEARgCPwJJAUsBPwFBBUMDRAg/A0QBJwE2ARkDSQJCAkkBRgFJAh8BAwEWARQBFgEXAV0BQAE2ATwBQgFJARUBGAEnAkcBHgEVASwBJwEcARUBRAEwAj8FQQFSBUMCRAE/AUQFQQJDAT4BQwE+AToBHgJEAj8BRAI/AVIBWQE/AR4BVwFZAQUBJAFVAV4BWQEqARcBAgEVAVMBJAEdAkcBHgEVATIBJwEWARUBPwEcAj8BQQI/AUQBQwFdBkMBRAJDBUEEQwJBAT8BQwJEAUIBUgFDAUYBUQFKAUQBFQFFATYCBQEhASIBQAFTARQBHwEVARYCHQJHAh4BPgFRAUcCJwE2AT8BQQJEAT8CRAFKCEMHQQE+AkMCQQNDAUQBPwFOAT4BQgE2AU4BRAEeATUBOAMFAQoBFwEFARQBNgFTAUcBPQEzAigBQgE/AUIBRAEnAj8BPQJEAz8BRAFZAVQFQwJBAUMHQQFOAlADTgNDAT8BSgE+A0kBHwFGA14CWQFfAVkBXwFgAV8DXgFgBF8BQgE/AkkBPwEZAz8BSgFZAV8FQwJSAkEBQwZBAk4CUAROAUMBTgNPAUsBSgE6Ak8BXgFfAV4BXwJgAVkBXwFeAWAHXgFVAj8CSQE/ASwDPwFEAT8CRAJDAUQCWQNSCEEBUAFOAVACTgFQAU4DPwEdAR4CRgMVAVMBEQJeA1UCXgNZAV4BFgIUAT8BRAE/A0QBPwEsAj8BPQE1ATMCRAFDAUQDWQJSAUsIQQJQAk4CUAFOAT8BSQE/ASYBFAEBAQQCXAEBASIBEQEbASoBWQEqAREBCQIhAgUBCgEQAQ8BUwNEAUMDPwEsAj8BOwE3ATgERAEqAVUBWQFSAREBXwFSAUABUgFLAU4CQQFDAkEBQwROAUQBPwFCATABHAEBAQQBAgFhAQEBDgEqARsBIwIJARABIwEPAiEBBQENAw8BPwFCAUYBPwJBAT8BJwEyATgBRQE3ATgERANZAlIBUwFLA1kBVwFLAUEBPwFJAUQBUAROAUMEPwEzAVYBHgEBAR8BDgINAQgCCgEjARIBDwENASEBBQEGAQ8BXgFVAT8BRAInAT8BQQE/AScBOAE1AzgDRAFSAVYCWQFSAUsBDwNZAksCWwI+A1ADTgFDBD8BMwFAAR0BAQE/ASoBEgEPAioBWQEqAS4BCAEJAi0BBgEPAWABVQE/BBUBPwFCAScBPQE1AzgDRAJZAVUCUgEXAVkBXwECAS0CXAFGATgBSwFDAUEBQwJOAVABTgFEBD8BPgFHASgBIAE/AioEWQEqARECDwEhAQUCDwFgAVUBPwEVBT8BJwE7ATUBPQE+AUMBRAJDA1kCUgEmAU8BSgMTAS0BXAEfAT4BTgFQBE4BQQFEA0MBPwEzAhUBRgE/ASoFWQEqAw8BIwEhASMBKgFeAVUBPwFEAkEBRAFJAj8BMQE1AT4BQQFSAUMBRAFDA1kCUgFMAQUBLQETAREBKgEbAS0BXAFOAUsERAE/AUQDSQE/AUkBFQEeAkYBSQZZASoEDwEKAQ8BKgFeAVUBRAEeAUQBPwI+AUIBPwExATUBVgFeAVoDRAJZA1IBRQEFAQMBXwFLAVABQQFDAUYBTgFQAkQEPwZJAR4BRgEVAUYHWQERAw8BEgEPAREBKgERAToBOQFHAlUBWQNQAVkBUwEsBEQCWQJSATQBBQEtAQMCEwEJAQUBLQEVAT4BTgVEAT8BUgFDAVIGSQEeB1kBKgERAw8BEAERASoBMAE5ATYCRwFaA1kBUgEdAR4BPwREAVcBWQFSAUsBBQItAQIBVQFZA18BLQEnA0QBPwFEAT8BQQFOAUMBUARJAUIBSQFGB1kCKgQPAhEBWQFPAVQBXgFTAVkBEQFJAx8BAgM/AVkBEQEjARcBWQEjASECLQFHAVIBUwFZAl8BAgFJBUQBPwJQAUQBUAFDAUYCSQI4AT0IWQIqAg8BIgERAVkBXgEwAV4BYAFMAVkBEQE/AkQBRgEeAS0BBQFZAREBFwEsAS0BKgEjAi0BFwFKAVABTAEWAUgBXAFGBkQBQgQ/BEkBJwEsATUCWQEEARQBCgEECVkBDwFZAV4BPAEaAQkBLQECAVwCAgFcA1kBBQEwATMBAwNZASIBTAE/AUIBAwNcA0MBOQEVAz8BRAJOAj8BSQFEAkIBPAE6AVkBCQEEAhQBIgFHB1kCKgEPAVkBDgEaATgEXAEgAU8GLQFeASIBXwFZARcBKAEeAQIBLQECAlwBRAJcAWEBQwM/AUMCQQFEAT8CRgIeARkBFAFZAQMCHQEUASIBQAJZATsCHAZZAmACVwNSAVcBUgFFAVIBVQIsAVMBBAEJAUgBOQItBGEBLQFcAQIBAwEtAUQBQwQ/AkEBQwNGAQQCFgEXAUsCUwE5AVQBOQE8AVkBHAE8AlIBRQZZAUcBWQFAAU8DWQFWAUcBAgIVAR4BRAECAUUBUgFcBWEBLQEZAV0BXAEdA0QBPwFEAVABRgE/AkkBIAJGARkBVgFgARcBXAE/AUQBSwFKAVQBJwFZAh0BQwE+AUwBWQFHAVMBKwZZATYBRQE9AUQBNAICBD8BLQFSARMDXAEDAlwBLQEUAVwBYQECASIBGQEDAT8BUgFQAUQBRgFQA0QBHQFaARgBFgEgAScCPwFEATsBHQFfAh4CQwEXBFkBXwEYAhwBLAE9ATgBTQEBASADAgM/ARMBIwItA1wBAwNcARQBLQIgAQIBPAFTBEQBQwNEAT8BNAE4ASIBGgEpAx8CFQE4ATMBAgEVAj8BPQFZASUBHAMsATQBQgZhAwIDPwEbASoBYQIjAy0BXAFhAVwBLQECASADRAM/A0sBQQFLAVIBQQEVAUEBLQFgBCkBPgFRAU8BVwFVAk8BMQE7ATgBPQEsAScDPwRhAQECYQICAUICPwFJASMBKgFhAS0BIwEbARMBLQEpAWIBKQIBASAERAI/A0MDUAFEARUDQQQpAiABHwIzAT0BJQE9ATQBHQthAgEBAgEVAR0BQQFQAUEBLQERAWEBLQEjARsBXAEhA2IBAAEpAj8CRAJSAVABPwJCAUkBQgIdAUoBSwJEAWECAQFhAQEBKQEBAUMBMwEsAQMBXAZhAQEIYQECAQMBGQJGAUMBQQEpAQACXAJhAmIBQwFGAWIBSQI/AUMBWQFSAUMIAQEgASkCSwIgAhUEAQQVAgEDYQEgAwEBUwFhAgEBYQEBAVwBAgEdAUMBQQFJASkCYgEpA2EFYgFEAUIBPwFEAV4DUgFJBEMBQQRQASkEIAQBBBUDYQEpASABHwIUAR0DAQFCASwBAgFcAQIBHgEsAk4BLQEFAS0CXAFPAUsBXAFhAQEBKQFGAQQCQQFEAVYBOwI4AUYCUgFfAkMCRAE/AikDAQNhASkBAQEgARUCQgFhAQEDYQEfAT8CRAE/AR8BFQInAQIBXAECAx4BXAEMAS0CXANZAWABLQFCAR4BGQEtAV8BVQFXARcBNQJGAR8BIAMfAUkBPwEgAT8BKQEBBCACKQIBASABQgJJBWECAQJGASACHwFcAgEBFQEeASABHgE1AVACXAJhAVkBOgFHAVkBXAItAlwCVwFgAQ8BHQEVAkYCHwMgBCkBRgFJAiAEKQEBASABQgJJAmEDAQFGAUkBRAJBAUkBVAEeAT8CRAJBAQ0BIwEEAQMBXAJhAVcBVgNZA1wBYQNZAQ8BLwEcBUYBSQFGBCkBAQcpAQEBFQJCAUkDYQEBASkBSQJGAj8BRgInAT4BMgFRATgBNAIMAQMBAgNhAR0BTQEzASUBRQEtAQICXANZAQ8BKwEdBUYBSQUpAQEDKQEsAx4BAQEfAUkBQgEeBAEDKQJJAUYBHwECAV0BSwFHAU0BHQE9BlwELQEDAS0BDQEhAlwBMgI8AUcBMAEnA0YBHwMgBCkBAQQpBAEBHwFGAUkBRgFCAUYCAQFhAQEBKQIBASkBJwI0AScBLAJKAUsBVQJeAUcBTAEWAQUELQIhARQBAgFhAj4BMAInA0YBHwIgBikBAQQpAQEBAAEBASkCIAJGAh4CQgEfASkDAQJBAkkBNAI5AWAFWQJgAVUBVgFAATEBMwJcAWEBAQEVAUkBHgEwAicEHwIgAR8CKQEVAkkBRgMpASABHwIgASkDIAEVAQIBQgEnA0QBPQEyATQBSQFGAUkBSgFHAUABJgFHAVMBXwNZAl8BIgFaAVcBVQFHAUUCNAFDAUQBFQExAScBPwUfAyABGgFHASUBHQFCAUkCKQIgAykBPwFABCABMwEfAUEBUQJKAT4CHgFJAkcBSgFfAV4DWQFFAjoBSgFHA1kCXwFVAU8BRwE6ATYBPQEsAUIHHwEpAVwCXgFVAUoBRAFJAgACIAIpAScBIAEyAUcBVAIfARUBQwEzAT4BQwEVAUYCSQFKAV0BLAE4AVgEWQFAAlkBVwFVAU8BNwJHATMCXwFXAV8BVwFVAVEBXAMgAh8BIAIpAQICAwJKATIBRgIAA2EBRgEsATIBFQFRAU4BQQEgARUBQgEsAScCRgEVAVsBSwFbA1cDUQE6ASUBTwJZAl8BOgE5Al8CVwI4ATYBRwFPAScBFQEpBSACAQMDAkYBFQEBBAABSQEpAT4BNAIfAT4BFQEfAUYBFQInAUkBRgFJAUIBQwFOAlcEYAFPAUcBNAJBAU4BPAFXBF8BYAJfAUsBMgFLAVsBXQFRAR0DIAEBAWECAQECAQMCRgEgAQEBAAFhAQEBYQIBAkYBSQMpAR8BRgECAUYCQQNKAT8BJwFEAUEBVwNgAV8BYAFfAVEBPwE4Bl8BYAFfAVQBSwFXAmABXwFXAUoBQwE0ARUBAgEgAwECAgEgAmEBAAphAh8BAQEfAUMCQQFRAUoBWwJPAUEBQgI0AU8EVwFRAlcBUAFBAUsCXwFXATMBTgNXA2ABVQFPAUsBSgE0AUkCRgEBAQACAQJhAQE="),
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
};