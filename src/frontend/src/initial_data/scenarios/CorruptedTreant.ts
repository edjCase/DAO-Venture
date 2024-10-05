import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "corrupted_treant",
    name: "Corrupted Treant",
    description: "A massive, twisted tree creature blocks your path. Dark energy pulses through its bark, its once-peaceful nature warped by an unknown force.",
    location: {
        zoneIds: ["enchanted_forest", "ancient_ruins", "scorching_desert"],
    },
    category: { combat: { elite: null } },
    image: decodeBase64ToImage("XzkWQ2VPaamVrbCZtZ6Dn4JcfEskSKylp6yQqY6Pjru8tuf0z6+rp6OlnKvBqdDaya/Xs6BIi5kxfo83fWA5YIw/foVgfHdhd4dxgmpaa0ogRqKXnsfJxc/YyqChmpqiksK/rLypnJRzjpeBlXNidZaIk3d0dpOTko+dkKCln1cwVEA1Q4qChmJcZpmpmB0hKnJWa2pLbV9TYLCLoEk5SVI/VZymn0EWRmBFY2RbX6Wgn35ieEY6RW9mb4uNinhwd5WBh4aCgIJ3fIJ+gFs/URoWJK2XoZV2jHqBeXRudIpxgXJycJ/GpmxubHyIeYmYiXyGgIyWi4OLgnJ7cWFlYlFUVZOGioJue21baZaLkGBMWVRLVEhFUU9IUUUlTQEAAQEBAgEDAQQBBQIGAQcBCAIJAQoPCwEMAQ0BDgENAg8BEAEOAQoBDgEKAREBEgEHAQoBBwIRARMBFAITAQUBFQITARYCEwMRARUCBgIAARcBGAIZARoBAgEbARwBDwEdAQ8BHQEeAR8BCQENAR4BIAEhBQsBDAULAQ8BHwEOARABHAEbARECCgESARMGEQITARQBBAITARUCIgESARMCIgIGAgABIwEEASQCBgEcARsBDwElAQQBJgEnDQsBHAEgARABDQEOAQsBDwIoASkBGwERAhIBIgEDAhMBBAEIAREBIgEEASMCFAEVASIBFAERAQgBEQETARQBIwEqAQYCAAIEASsBAAEMASwBBwEtARkBLAIPAgsCDwEhAREKCwEPAS4BHAEKAQ8BDAEPAgwBCgEDAQwBEQEDAREBFAEiARgBGwEiAQEBBgEaASoBFAEiARMBFQEiAREBEwERAgYBAAEvAQABKwEwATECMgEZASUBCgEdAQwBEQMTARwBEQEdDAsDDgEPASkBHAEPAQoCEQEzAREBEgITARgBCgEbAQwCBAEaAxQBEwEEAQgBIwEqAgYCLwErASQBGwEGARMBFgERAxMBFAEqAR0BFQIRAQ8BHAoLAw8BHAEpASgBKQEOAhwBCAIcAQgBEQEKAREBGgEEASUBBwIEAQABIgESAREBEwEiAScBJQEGASoBBgIvAQEBNAE1ARgBEwEbAREBEwIUAhUCEwEdAhEBMwoLASsCCwEPAQ4CDwE2ASkDDgIKAQwBBwICAgABKwIAARkBLwEYASIBEwE3ARcCIwEqAQYCLwE4ARgBCgEiAREBGwEAARUCEQEcAQ8CEQEcCQsBKwILAisDCwEPAQ4CDwEmAQoBDgEpAQoBKwIMAgcBIgIbARgDGQIvARgBFQEAARkBGwEaAQYDLwIbARYBAAEGAQABBAEcARsCCgEPASABMwEiCAsBKwILAi8BKwELASsCDwEcAR0BKwIQASsBOQErAQoBOgIRARYDIgE7ASUBGwEKASICAAErAREBIwEaAQACLwEjASkBBAIAASQBLAIKARsBHQEMAQ8BHAgLASsBCwEvAQsCLwMLAS8EDwErAhABKwEKASsBDgEHARMCEQEEAxECGwERARUBIwEkAS8BGgETAgACLwElAQwBAAErAS8CJwIKAR4CDAEPAQsBDwEKAgsBIAQLAi8BCwEvAwsBKwELAg8CLwErASABEAErAQoBKwEKASsBOgEHBhEBAgIRAQIBBAEbAy8BAAIvASUBJwIvAQoBDAEnAR0BDAEeAScBDwEcAg8BDgELARwFCwIrAQsBLwMLAisEDwIrARABKwEMASsBDgEvAQcCOgEbASMBBgEaAREBGwEEARICEQEiARgBLwIABS8BLAIKAQkBJwIHAQoBDwEKAQ0CDwIgBQsCLwELAS8CCwEvASsBCwUPASsBPAErAQwBLwErAQoBDAIbAQoCEQETAQABFQIEARMBAwECAQcBDAYvATIBKQEnAQ4BCQEnAikBEAEPAQoBDAEPASABDAcLBi8CCwMPARwBEAI8ASsCLwIKAQwBGwIRAToBGwElBi8BBgE6AQQBLwEAAy8BPQEnAQwBHgEHAT4BCQEKAQwBEAIKAQ4BHgEOAQ8BCggLBC8CCwUPASsDLwEKAQ4BCgEiAhEBBwEnAhsBJwIlAQwBCgEAASoCAAEaAQACLwE/AT4CDgEKAQQCEQEIAREBCgEiARECCgQPBwsBDwEvAUABLwErAQsDDwFBASsBLwQQAg4BAgEEAwwDGwIRASMBOgIvASkBCgE3Ay8BQgEpARsCCgMRAQcBBAEVARECDAEQBA8ICwEPAS8BDwErASEDDwE8AS8IEAEOAgwCEQElASMBBAE6AhEBAgIAARsELwFDASkBGwEHARQBBAEbARMBKgEGARUBEwEUAREBEgEQAw8HCwQvASsBAAJEAisBRQEvASsEEAMOAgwBBAERARQCEQEVASoBGgEABy8BLAEpASsCGgEAARQBEQESAUYBHAERARwBCgEcAxAEDwELAQ8BCwUPAioBFAJEASsIEAEOAR4BEQEMAQ4BCgERARUBKgE3ARQBLAEjCS8BBgIvARcBPwE7ASIBEwEVATMBEQEiAQ4EEAgPAS8CRQEvASoDOAEvA0UEEAEvAg4BBAERAQQBEQFHASUBGwFDAS8BSAIOCS8BKQIKAkkBDgEjARwBFgEjBxAIDwJFAS8BAwE4ARQBAwEvAkUCEAEvAhABLwIQAQoBEQEVARMBBgMAAScBLwEOARABDgcvATYBSgEOARACSwEnAxABDgYQBQ8BKwUPAi8COAErAS8DEAErAhABKwE2ARABDAIRAgQBEwEGAhoDKwFMARAGLwMOAhACTQIQAUgBHwNMARABTgEoBg8BKwEvBA8CRQEqATEBLwFFAS8CEAEvARACKwEOASsCFQIOASkBQwFBAQ4BOg0vAk8BEAJNAUwBLgFQAS4BTAEQAU8BLgEoARAGDwFMAS8BEAEvAQ8BKwJFAhEBLwJFAisCEAErAi8BDAEEAw4BNgFDAUgBDAE2AQwHLwErAi8BNgFRASgBEAFMAk0BEAFSASgBNgIQAU4BTAUQAS8DEAQvA0UBGgEUAS8CRQErAS8BEAErAS8BTAIQASkBDgEQAQ4BNgJIAigCUAFRBS8CKwEvARACTAIQBE0CEAEOAVMBTgEQAUwFEAEvASsBLwErAQABLwRFASsBNAJFBC8BKwE6ASsBDgEQASkBJwE+AQ4BNgNIARACSAEQASkBRQQvAisBUQEQAS4BKAEQAVQCTQFPAhACLgEQAUwIEAMrAQABLwRFATQCRQEvASsCAAFEATwBCgErATYBKQEQAVEBEAEeAkgBLgEOAkgBKAFSAQ4ELwIrAUgBEAEuARADVAFNAUwCEAFNAUwBEAEuBxACLwMrAkUBLwdFAS8BKwI0AS8CEAEpAQ4CKAEfAUgBUwFRARACSAFMAQ4BHgQvAisBUAEQAUwBEANUAxABVAFSAhABLgcQAy8BKwFFAisBLwRFAisBAAI8BCsBJwEpAQ4CUgJIAVMCEAFIAVMDEAUvASsBLwEQAUwBEANUAhABTQFUAU8CEAEuBxABLwJFAQABLwNFAS8BRQIvA0UBLwMrAS8BDgEQATYBKQIQAVMBSAFTAQ4BLgJIAUwCEAUvATwBLwEQAUwBEAEuBVQBTAEuAhABLggQAVAERQEvAysDLwErAS8CRQIvAT4CEAEuATYCEAFTAkgCEAJIAUwCEAUvASsBLwEQAQ4BEAFMBFQCEAEuAhABTwcQAS8ERQEvBUUBNAE8AisERQEvAxABKwEQAQ4BUwFIAVMCEAJIAS4CEAIvAQACLwErAQABEAEOAhACVAFPARABTAEQAS4CEAEoCBACLwJFAS8DKwFFASsBRQE8Ai8CRQIvASsBLwEQAS8BLgIOAVMCSAIQAkgBDgEoARAFLwIrAR4CDgNUAQ4BDAIQAS4CEAEoCBADLwEQBUUBEQFFAy8BTQEQAUUBLwIrAS8BDAEuAQ4BEAFTAkgCEAJIAS4BQQEQBS8CKwEsAg4DVAE2AxABLgIQASgFEAEvARAELwEQAS8BAAEvASsBRQEGASsBAAIvAxABLwQrAR8BDgEQAVMCSAIQAVABTgEOAT4BEAUvAisBPgIOAVQBTQFUAg4CEAEuAg4BLgYQBC8CEAErAy8BEQE0AUUDLwQQAisCPAErAhABUwJIARABDgJSAg4BEAEvAgACLwIrAT8CDgFUAU0BVAEOAhACDgMQAQ4EEAIrAy8DEAIvAkUBNAErAi8FEAMrAUQBKwIQAVMCSAIOAT4BUgMOBS8CKwEvAg4BVAFNAVQBDgQQAQ4HEAMrAi8DEAQvASsBLwFFAS8FEAMrAUQBPAFBASsBSAEfAUgBDQIOAScDDgEvAQAELwErAS8CDgFUAk0BDAEOARACDgMQAUwDEAErATQDKwQQAy8BKwFFAS8BAAIvBRACLwErATwBRAE+BC4GDgEvAQADLwEAASsBAAIOAVQCTQENAg4IEAErAzQBLwQQAVUDLwErAUUBKwEvASsBLwQQAg4CLwJEAg4CNgFBAR8FDgEvAgACLwEAATwBLwIOAVQBTQE9AToDDgYQASsBHgE0ASsBPAUQAy8CRQERAUUCLwMrBQ4BAAErAUQBPAYOASMBFAIOAVYCAAMvASsBAAEMARsEPQEHAQoHDgErAjUBKwEOBBABKwMvAQABRQERAUUBKwEAAi8BAQE0AQ4BLwIOAScBKwE8AUQBPAUOAQoBKgFWAQ4BDAEABC8CKwEjARgBVwFJAj0BSQEKAg4BSAQOASsCNQEKBhACLwFFASsBLwERAUUBAAMvAgoCLwQOASsBRAE8AR4DDgEiAgACCgEOBS8CKwEkAUcBGAFXASQDPwE9AkMEDgErATQCNQQQAQ4BKwIvAUUCKwFFASsCLwErAQABKwEvAgoCDgIKATwCNAE8ASsCDgIKAQQBKwEOAQwFLwIrAS8BIwJHASMBVwFHATMBCgYOASsBNAE1ASsBPAQOAisBLwJFASsELwE8ATQBKwEkATQBDgEuAw4ENAMOAUIBVgEqAQwBDgEYBS8BAAErAS8DIwFHAVgBRwFKAwoEDgErAjQCLwErAw4BLwErAy8BKwEvAkUBLwIrATwBKwEKBA4BKwE0AisBPAErAg4CCgEGATsBVwcvAisBGQQEASMBRwE7ASwDCgEOAQoBKwE0ATwBCgEOASsCDgEvASsBPAEvAkUBLwEABC8BKwJEASsBDgEKAg4BKwEvAQoBKwE0AUQCCgEMARMBBgEYAQwILwIrARsERgIzAQcFCgErAS8BPAEKBA4BKwE0ASsBLwJFAS8BKwQvASsCNAFEAQwDCgIOAQoDKwEKAgwBEgETAS8BOwcvBAABRgE6AQcCDAcKAQ4BLwErAQoDDgErAjQCLwFFAy8BGwEKAy8DNAErBAoBDgMrAwoBDAIKAUYBJAIvAQABLwEAAy8BKwIAATwBNAEEAQcCDAIKBg4BLwErAg4BLwErATQBPAMvAUUCLwMKAi8BKwE0ATwBNAEbAwoBKwEvASsHDAFGAy8BAAIvARQBLwFFAS8BKwQAAQcCDAIKAQ4CCgEOBQoBDgE6AjQBKwIvAQwDLwQKAVkBLwErATwBNAIrAwoJDAEDAi8BAAE3AS8BGgEAAy8BKwIAATgBNQEAATUDDAcKAQ0CCgErATwBNAErAi8BCgEjAS8BRgYKAS8BKwE8ASsBWQoMAQcBIwEvAgABLwEAAi8BAAIvAUUBLwErAQABLwFaAjQBPAE7AgwBGwgMAS8CKwMvAQoBDAEvAQcFDAIvAisBLwQMBQcBFwgAAS8DAAQvASsCAAExATABRAI8AVkBWAE9BQcCRgYvAQwBOgEbAUYBGwIMAUYFLwFGAwcCRgEEAiMDMAE4BAABLwEAAS8CAAQvAUUBLwErAi8CMAExAloBWwE1ATAGMwFGBC8CRgMbAwQBRwFGBC8DRgJHAyMCRwEiAQUBAAE4BQABLwYAAi8DKwEvAQEDMQIwAUQBNQI4ASMDIgMvAVwBIwJHAUoBRwFKAiICSgE7ASsBLwErBCIBSgIWATABOAEFATcBAAI4AQABNwMAAS8LAAErAgACAQIwAgEDOAEWAkoCLwJdAloBMAEBARkBFwE7AxYBWAEZAisBSgMWAQUDKgEGARoCFAIAAjcDAAEvAwABLwYAAS8EAAIrAjgEAQEyAVoBXAIvAlwBNQFdATUBAQFaBAECMgFaAisBXAMwATEBFAIAARQBGgEGAQABNwEAARoBNwMAAS8CAAEqARIBXgcAASsEAAErAUQDOAFbATUCKwIvA1wDNQETAzgBAQFaAVsBNAI8AysBOAM3AV4DAAM3ARIDAAMvAgABNwEqAjcDAAI3AwABKwQAATgCNQUrAVwBXQI1AVsBEwEUAzgBNQQ0AjwCKwE0A14BAAE3AQADNwEAARoDAAIvAwACNwYAATcCAAReAjQBKwE0AysDNAU1AjgBWgE1ATQBNQI0AzUCNAErA14CNwIAATcCAAEvAQACLwEAAy8KAAE3AgABXgEGAl4HNAU1ASoCNQYqARQEKgEGARoBFAE3AgABLwQAAS8BAAwvAQABLwYAATcHAAFeEioCXgEqARoCNwcAFy8IAAJeDioEXgI3BwABLwEADC8="),
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
    unlockRequirement: { none: null }
};