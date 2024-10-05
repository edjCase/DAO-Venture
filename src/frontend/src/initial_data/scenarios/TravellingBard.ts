import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "travelling_bard",
    name: "The Travelling Bard",
    description: "You encounter a bard whose lute is suspiciously in tune for someone who's been on the road. His hair is perfectly windswept, and you swear you can hear a faint background orchestra.",
    location: {
        zoneIds: ["enchanted_forest", "ancient_ruins", "scorching_desert"],
    },
    category: { "encounter": null },
    image: decodeBase64ToImage("X21+X2h/aFxoZYQ/f3JAZVYuRm88QLZ4VaxoRaBgPK9+V7Z9SsF9R8V3M9aYUOO/daSAXZN6Wq1yQdRuLY8sLHdmT2iBgVczXIRLPXJBRVs0RbJ1TKV7WmF8c6JfNV9vc3a2nls5RHE5Q9KedOG7cea8bFBOW5l6Ro9tWJBaRX9oajscPotQOJtrS8CwfY5tRpJ1V3RISMelb6p9VJN3XIJSTJJyUZZbTJFkUKN3VqF3RJxuTZlkVDFFYZpwWJ5wVJ50TGRSTXdQPic0VjNSYZhwZah8NoxeU4leSzs6SodzOqJ4WUNGU0FLUnpSSJlzXphpU5dvU3RKT4lnWI9wSYplVGJIRjxNWmxTRYJgQGF9Z4BiUIliSHpaTXtgUAEEBQUDBgEFAgcCCAEFAQkCAQEAAQoCCwEMAQ0BDg4PARAGAAEBAgABAQEAARECAAERARIBDQETARQBFQIWAQMBFwEEBQUBBgEYARkBGgIbAQgBBgISAhEBEAEcAQsBEgIMAQ0ODwEBAQAGAQEdBAEBFgEBAQADEgEeARMBHwEWASABHwEXBAUCBgEYASECGgEiAhsBEgEMAw4BIwEPASQBDgEMAQ4BJQsPAhEBHQEBAgIBJgsBAScBKAEpAQwBEwIeAhYBKgErAwUBBgIZAhoBLAEtAgwBEgEMBA4CDwEkAQwCDQEOCQ8BLgQRAhABLwEYATABDgEfAQICFgIgAgEBHgEIAQ4BDAMeAQwCIwErAwUCBgExARoBBQMMAhIFDAEOAg8CDQEPAQ0IDwEQAREGEAEyASMBBgEOARkCCAEWAiACMwENAQ4EEwEeAQwBIwEkASsDBQEaARkCBgkMAgsCDwEMDA8BAQERASACFgEQAjIBCgIOAgYBGAEsAQ4CAQEwATQBEgENAR4EEwE1AQ4BJAErAwUBBgEZARgBLAIMAikBCAISAg4CCwEOEA8BCAEBBBYBEQIQAQ4BGgEGARkBCwEOAQwBKQE2AQ0DEwIeARMBGgEIASQBKwMFAQYBMQIYAQsCDAESAQsBKQEGAQ4BDAELAQ4SDwERARYBAQEWAgEBNAEQAQoBCAIGARIBDgEYASkBDAcTATcBCwEOASsDBQEGAxgBGwMMARsBGQMMAQsBDgUPBBMKDwEgAhYBAAEyASMBGAEKAQ4BGAEGARgBGwEYAQsBDgMTAR4BEwIOAQsBBQEXASsDBQEiAxgCCwIMAQsBBgELAQwBIwEOAw8DFAITARQBEwsPAQ4BMgEtATIBDgEzATIBDgEGAxkBDAEIAxMBHgUTATcBBQErAwUCBgIYAQsDDAEbAQoCDAEPASQCDwEUAhMCFAErARQCEwoPASQBAQEMAQ4BJAElARkBDAEYASEBGQEMAQsBNwEsARMBHgMTAR4CEwEtARgEBQEaAxgBCwEzAgwBBgELAQ0BDAMPBBQBBQIjAQQBFwEUCg8BFgEmAQwBDgIkAQ4EBgILATgBBgEJAQ0CEwQeASwBCwQFASEDGAEbAQoBKQEhATICDgQPAxQBHwQPAQQCFAgPAxEBIgEOAw8BGgIGARkBMgEbARkBKQE5ASkCEwEsARsBDQE6ATsBCgMFAQMBPAQYATcBCgEOATICDgIPARMBFAEFAj0BFgEjATcBDwEUAQUCFAsPAQ4BGAMPAQwCBgEZATIBLAEGAQcBLQE+ASkBNwIbAQ4BKQE7AQoCKwEFARoBNQEYAQYBGAEGBA4CDAEjASQBFAEFAT0BBQEPASABDwEqASMBDwEFARQNDwELAg4BDwEMAwYBGAEGAQkBDgEzARgBOwE/A0ABOQEtAQoBBQErAgUBGgExAhgBGwEMBA4BGAEjAyQBKwEIASMBIAIPARMBDwEMDw8BQQEmAQ0BDAEGAhkBNQFAAQ0DDgEtARwBCwFAAS0BOQFAATkEBQFCAhgBBgE3ATIDDgEEAQUBDAMkAT0BQwEXARYCLgEqAQQBHxAPASQBBQEYAgYBGAUMAQ0BOQEcAQkBQAETAkABOQErAQUBGgEhAxkBBgMyAg4BGgEiATUCIwEEAR8BPQEWASABIwEqASABDwEjASoQDwEkAhoBBgEYAgwEDgEzARABCQEOARMBQAE6AQUCKwEaAgYBMQEYAQUDMgMOAiIBFwEyAUMBFgFEAT0BLgEgFg8BMgEaAQYBGAIbAQwDDgFAASkCDgEzAkABKwIFARoCGQExARkBHAMyAw4BMgErAQQBNQErARcBKgErAiAEDwEuEQ8BJAEaARkBLAEKATMCDgEMAg4CCwEzAhABLQErAQUBKwMZARgBBgMyBg4BKwEFARoBBQIUASsDIAEPAS4BFgEUCA8BRQEPATwCRQMPASQBBgEZASwBBwIMAS0DDAEOARsBLQIQATgBKwEFAhoCGQMYAzICDgEKAQ4BCgEFARgCLAEFAhQBFwEgASICIAEFAkYGDwEgARcBDwEFAUUBRwQPAQYBGAEsAUABGwQtAQkBCwEKAUgCEAE4AwUBBgEZARgBQgEiATEDMgQOASsBAgFJASwDCQEiASsBCAEjAQUBIgETAR4CSgUPAQUBDwE1A0UDMgEOAQYCGAEKAUABOwEYAUABCgItAQoBHAIQAUsBKwIFAQYBGQEpASwBBgE7Bg4BKwIWAUQBGgEYAgkBLAFEARcBJAEYAQ8CEwIWBA8BDgEUATwBRwEiAgUEMgIGARQBCgEpAUABGAEtAUABKQEtAQoDEAErAwUBBgEiAykBLAEOAQoDDgFBAiABHwEWAT0BCQFMARgBKQFEARYCDwEgAQ0BHgEWAR8BIAIPASABGgFHASMCDwEFAQ8DMgEKAQYBGQEeAQoBOwEtASwBLQIpAgoDEAErAwUBGgEhARkBLAEpASwEDgFJAiABFgEgARYBPQFJAUQBTAMYAUkBMgEpAh4BPQEWAiABNwFFARgBDwEjAg8BJAMyAQoBOQEZAQYBLAEKAS0BKQEsAS0BOQEtAhABEQEQAREBBQEaAgUBIQEGAykBGAMOAhYBHwEWASABRAJDAUkBPQFEAU0CGAIXAQkBLAFJASsBPQFFAUcBRQFHASsCDwMkAzIBCgE5ARkBBgEsATMBOwIsAjgBTgEQAU8CAQEQAQUBKwEFARoBBgEYAQYBGAEpAUABEAEKAT0BHwFEAUMDPQEyASsCQwNEBCUBIgFDARABPAJFAQUBKwEjAQ8EJAMyAQoBLQIGASwCOwIsATgBUAIQAUUCHQEAAisBBQEZARoDGAEpAUACEAFDAT0BRAEJAQ0BHgETAQ4BQwIrAUkBDgUlAQ4BGAIQASIBKwE8ARcBIwEFBCQDMgEKASkBEgEYASwBCgEtAhMBOAFRASgBEAEVAh0BFgMFARoBIgEGARgCKQEKAhABQwE9ATcBPAFSAUUBJgEPARQDDgQlAQ4BDwEOAUUBPAEaASsBQwFFASoBRQEiAyQBDwIyAQ4BCgEtAhgBHgE5AS0BCAETAS0BOAEoAREEHQErARoBBQIaATEDGAEKAxABKwEIARQBIgIPARABDwMOAiUBFAErAR4CDgEeAisBQwE9AUUBNwEUAQ8DJAEPAzIBCgEtAhgBHgIQBCkBPwEgAx0BHwErARoBBQEhAQUBGQMYBAoBIgEFARQBSQIuAUcEDwEeAQ4BKwIGAw4BIwErAT0CQwFTAUUBIAQkATIDEAE5AhgBHgIQAiwCKQFUARYBAgEfASYCKwIFAhoBGAIpASwECgErAiIBSQIuAQUBDwEjAw8BEwEUAQUBEwIOARQBJAElASsCPQckAhACMgEKAhgBHgEQARECGAEpAgwBFgEfAhcBBQIrAQUCGgEYAwkBEAMKARAEKwEUAysBIwIPARMEDgEeASsBJAElASQBBQckASMEEAFHARkBGAEeAhEBLAEYATsBLQENARYBJgIXAysBBQIaARgBCQE3ARgCDgElAQoCEAMrARQCHgEFAR4BBQITBA4BSQIrCSQCCgQQATUBIgEYAR4BEQE0ASwBGAEQATgBAAEWAgYBBQMrARoBIgEFASIBGAEJASkEDgIQAysFHgMTAw4BQwEFASsBDgEFByQBIwEyAQoEEAEGASICGAEWATQCGQE/ATgBAAEdARYBBQIaAisBBQMaASkBCAEpBQ4CDAEIASsBBQcTAgYDKwEYASsBFAIkAQ4DJQEQAQoBMgIKAxABBgEZARgBLAEdASoBBgExAVUBKAEWASYBHwEYAScCKwEFARgBSQFWARoBQgEJASkFDgIMASQBEQIrBBMBBgEaAisBHgEiAhMBPQEsAiUBDgIlAzIBCgEyAxYBEQEGAhgBLAICAiEBVgEVAR8BKwEmAU0BQQEhAQUBDQEIASsBHgEFARgBCQEIAQkGDgYrAgUCKwEeAhMBKwFDASsBVwEsARQDDgELAg4CCgEQAhEBFgERAQYBGQEGASwDFQEhARcBAgIfASYBAgFMAVgBTQETAQUBQQEYASsBBgEYAQgBEgYOAisCBgQrAQYBFAEeARMBKwFEAT0CQwEsAR4HDgEKAhEBMAERATABBQEGAhgBWQFKAhUEHwFYAiYBAAIVAUEBGQEVAUkBIQEYAQkCEgIOARECDgEkASsBBQEeAQUBBgEYARQCQwE9AUMDRAM9ARQHDgERARABAAEVAVMBVAEaAQYBLAJZATQCRQEdAR8BFgEdAVgBTQMmAUEBTAEiAQABFQFJARkCCQEIAQEBEAEAAw4BBQETASwBKwJDAj0CRAFDAkQBFgNEBw4BJQEQAREDFQEvASwBQgEsAlkDBwEAAR8BFgECAVkBLwFBATUCKgEFAR4BTAEVAVgBBQMpARUCWgELAw4CKwE9AUMDRAIfAUMBRAEWASACRAEfAQ4BDAQOAQsDEQIwASgBWQFCAVkBLAFGAQ0BWQFKAREBAAFaAh8CEwIVAUEBVgEYAVYCKQEVAQIBQgEZASwBEgEAAVoBAQILAQ4BKwFDAT0DRAIWAUQBQwIWASABRAIdATYBJQIOARwBEAIRAVsBEQEVAREBXAEpAR4BEgFZAQACHgFKAQABHQFFAVoBHQETAUYCAgFYARUCWQFKAVkBFQECASYBTQFCAQkCEgEjAgsBDgIrA0QDFgEfAUQCFgEgAUQCHQEgAQ4BMgQQAhEBFQEdASgBGAEOARMCJwFYAQcBGwFKAQICHQFaAQABSgEVAgIBQQEVAQIBFQIsAi8BOgEmAUkCGAEpAQkCDgELAUMBKwNEAR0CIAEmAR8CFgEgAUQCHQEgAQ4CEAQRATQBAQECAS8BWQIOAkoBHgFCASsBGQFaAQABCAIdAQIBFQIAARUCAgIVARMCLAFKAR4BCQFCAQkBEAEsAVQBCgEzAT0BKwE9AkQBFgIgAVcBHwEWAiABRAEdARYBIAELARABMgFLAhEBJwEWAVoBAAEnAhMBHgENAhMBBgEUASwBFQEAARMBHAFaAU0BJgFYAUECFQEIAhUBSgITAUYBEwEeAQ0BHgEsAUIBVAEKAQkBPQErAT0BRAEfAyABKwE9AUQBFgEgAUQBHwEgAT0BCwEKARABCgEzAUoBJwEVAQABLwITAR4BAgFaAhQBCQITAUIBXQETARQBAAImAU0BQQMVAQ0BEwJKARMBCQESAx4DDAISASsBCAErAT0BRAEgAUQBPQEKASsBPQFEARYBQwE9AUQDCwIQATYBOgFUAS8BWQEeAhQBQgICAhMBRgITAR4BDgETAR4BQQFXAQICQQEAAU0BFQEeAhMCVAFKAR4HDAEIASsBDAIrAUMBRAE9BCsBPQFJAisBSQEMAwsBDgE6AQsDWQEYAS8BWQFKAhgCEwFKARMBDgMTARQBAAFXAU0BQQECASwBAgIVAScBEwJZAScBSgEnAgwBRgUMAQgLKwEeAQUGDAEJAQ4CCQEbAQkCQgEYAxMBHgFZAQ4BEwIVASwBEwECAUQBVwJMAgIBNQFeARUBTgEpAS8BSgEJAUYBVAFKAg4FDAEFAisBBQErAQkCKwEFASsBBQIMAg4BDAELAgwBEgIIASkBNQFCAVYBSgIsAhMBWAEVAgADFQFcAU0BSQECAUkCFAEGAQMBKgFdATEBKQEVAVkBEgENARUBWQJGAQ8CDAIOAisCGgEFAQ4EKwEKAQwBDgEzAToBDAEOAgwBDgElAQ4BDAEIAQkBCAQTAR4BGgFYAQIBVgFBAUwBAAEVAVgBQQJNARQBIgEGARcBBAE3ATUCWAEJARIBDQEOAUoBWQFKAQ4BVAMOAQUBKwEGASwBDgEkAisCBQEKBQwDDgElAQ4BRgIMAQgBHgITARQBEwEUAlYBTAECARUBJgICAkkCVwEaAR4BLAFJAVICTAEmAQICCAEJARIBSgEMBEYCDgEjAisBBQIOAisBBQEOAQwCDgEMASUCDAEOAQ0CDgEMAQ0BHgQTAR4CFAFWAUECTQEAAkwBAgEVAkkBKwITAR4BGAJNAUEBTAFDAhQBKQFCAQkBEgENAQwBCwEOAhIBCwErAgUBDAEOAysDDgclAg4CDQEMAQ0BEgITAUYBHgEUAQIBTQEVAU0BFQNBAU0BJgErARMBDgITAQ4BJQFJASYBSQFNASECVgEpASwBCQENAQgBCwEbAw4CKwEaAg4BKwIaAg4EJQEMAg4BDAESAQ0BDAUNAQICQQEVAVcCFQEnARUCTQFJAQUBDQFWASICEwEeAQ4CEwFEAVcBTQFYAUwBQgEZATUBCQEpARgBNwIbAQsBDAEFARkBGgESARsCKwEFASYDDgEMARIDJQQMAQ4BEgQNARUBWQJBAQIBJgEVA00BTAFJARgBEwIUAhMBHgEOARMBSQEmAQIBWAFMAUIBGQE1ARgBMQFYATcDCQEYAQUCGgEpATcEKwEFAQYBBQMMBA4BJQEjARIBDgQNAU0ETAFNAUwDDgENAUEBGgEeBBQCEwEFASYBTQFXBEwCFQFZAQkBKQQYAQYBBQEYAQYBGgMFAysCBQEbAhIDDgIMAQ4BDAIdAg0BTQFMAU0BQQECAUwBSQQOARMBSQIUAQUDFAErAk0BSQE9AUkBTAFJASYBTQFXAUcBCQFYAykBBQMeAhgCKQM3AggCDAUOAgwBDgEIAQIBJgEeAVIBFAEVAQIBTAJNAhMBFAMTASsBSAErARQBGgIrAVcBPQFNAT0BJgFNAUkCVwFNAVcBTQFMASkDVgErAQUBKwEFASkBNwEpAQwCDgEMAQkBGwESBQwDGwESAhgBLwEpATwBVgEmAUwBAgFBAVgBHgEUAR4BGgIUAUkCKwEFAVkBKwEaAUwBSQEEARcBTQFDAT0BQQFNAisBJgFJAUwBVgEFAzUCGAEMARsBDAEbBAwEDgIMAhIBGwExAgkBCAE3AVYBJgFMAVcBSQFMAQ0BHgEYAR4BFAErASIBKwFJAgUBKwEVASsBGgErAQQBKwEFAU0BQwI9AkMBPQJJAQUCFwEhAggBDAELAjcBCAE3AggBGwEIAgcCKQELAjcBCAEGATcBCQEiASwBIQFWAVcBSQE3AQQBSQEhASwBBQErARQBKwJJ"),
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
    unlockRequirement: { none: null }
};