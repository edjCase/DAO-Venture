import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "mystic_forge",
    name: "Mystic Forge",
    description: "You enter a magical smithy where the hammers swing themselves and the anvils occasionally burp fire. It's either a blacksmith's dream or a safety inspector's nightmare.",
    location: {
        // zoneIds: ["mystic_caves"], TODO
        common: null
    },
    category: { "store": null },
    image: decodeBase64ToImage("TEcrLU4uMFc+O1YuN29RPzQnLzkqM1E0P2Y/QFxCRSggLCEfNBwhNyEjPCEmRiUmQR0hOSouRTI1UEg0PTI6TklOYywtdT1GYR4sjTA9XS89YzM4TD8/VFVTeylIqBxH1DZEiDRPrjhDa582Nvl9AOtnCBeG8lsrKieq8XZGKyma70QzO2xjWl1ubWRigEM9RWlFKVZ2ojovODc5TCgkOSIhOjArOjgtNTFAZFlDVF9MVTkwPyUjMlBFTz5LdT02RjpZgUVcjUBdfTxklkhBVzQyRjdclT9dikdEUzdwsChbrjkzSgEAAQEBAAECAQMDBAEBAwQBAAIEAQIDBAEDAwQBAgQEAQMDBAECAgQBAwMEAQMDBAECBAQBAgYEAQIDBAEBAQIDAAIFAQACBgQBBAABBgIABAIDAwICAQECAgEDBAIEAwEBBQIFAwIBAQMBAQEFAgYEAAEFAQEBAAEDAQUBAAEFAgcBAQQCAwgBAAICAwgFBAEIFAQCCAYCAQEDBAECAQEBAgEJAQIBAAEDAQEEAAIGAgUBBgEFAQYBBQEBAwIEBQEAAgIBBQ4BAQABAQIDAQABAgEAAQIFBAECAwABBgIAAgYBAQEAAQUBAQMAAwICBAEIAgUBAAgFAQICAAEFDgEBBgMBAQAGBQIGAQEDCAIEAQABAgEJAgACAgIFBAACAgEAAQEBCAECAQcBBQEKBAUPCwEMCAsBCgEAAQECBQEHAQEBCgEFBAYCAAEDAQQBCAEAAQMBAAEGAwUEAAECAQEBAAQKDQsBDAYLAQwKCwEKAgUEAAEGAQUDAAEDAQICBAEFAQcDBgEAAQUBBAIAAQUBAgQKDgsGDQIMDgsBBgEAAgUBAQEFCQACBgEIAQQBAAEHAgIECg8LAQ4CDwIQAQ0CDw8LAQoBBQIKAQcBBQECBgADBgEFAQYCAQECAwoRCwEOAREBEgURDwsCCgEGAQUBCgEDAQABCAECAQUDAAETAQUBCAMEAQEDChILAxECFAEVAhERCwEKAQUBAgIBAQABAgEIAQEBBgIBAQUBAgIEAQMDChMLAREEFAEVAhQSCwEKAQYCAgMAAQgBBQEAAQEBBQECAgABAgMKEwsBFgESAxcBFQIUEQsDCgEFAQIBCAMAAQYBAAEFAQEBAAEIAQEDChQLARgBEgMXARUBEgEZEwsBCgEFAQIBAAIIAQABEwIFAQEBAAECAQgDChQLARoBEgMXARUCEhMLAwoBBAEGAgACBgMBAQIBAwMKFAsBGAEbARICFwIVARITCwMKAgQBAgEIAQUBBgUBAwoUCwEYAhsBHAEXAR0BFQEXEwsDCgECAQMBBgEIAQUBAAIHAQUCAQMKFAsBHgEPBRUBFxMLBAoCCAMBAgcCBQQKFAsBGAESBRUBEhMLAwoBBwEGAQgDAQEHAQUCAQQKFAsBHwEgBRUBGBALAgoBCwMKAQUBAQECAQACAQEHAQACAQEFAwoTCwEWAR8BFgEVAR0BFQEhARUBGBALBQoBBQEAAgEBBQEAAQIBBwEAAQoCBQMKAQsBChELAQwBHwEeARUBHQEXAR8BIgEgCwsCCgILAQoBBQEjAwoBBQIAAQEBBQIBAQoDAAEFBgoPCwEMAQ4BHwEYAhUBFwMfAQsBHg0LAQoBAAEkAQAECgEABAEBCgEBAQoBAQEFBAoBJQEAAQoOCwEMAx8BFQEXAR8BJgEfAR4BDAEeBAsBCggLAQoBJQEkASMDCgEGAgEBAgEDAQIBCgEBAQoCBgMKAScBJQEjAQoNCwEOARgBHwEmAR8BFQIfASYBHwEeAxgBHwsLAQADJAElAgoBBgEBAgABAwECAQoBAQEKAQABBgIKAQABJQIkAgoMCwEOARgBHwEmAh8CJgEoAh8BJgEeARgBHwsLAQABJQMkAgoBBgEFAgABAwEBARMBAQEKAgUBCwEKBCQBIwEKCwsBDAEOAR8CJgIfASYCKAMmAR8BGAEfCQsBAgEEASkDIwIpAQQBBgEKAQEBEwIBAQoBAQEKAgUBCwEKASUCJAElASQBJwEKCQsBDAIfASYBKgQmAygBJgEqAh8BGAEMARgBHgEMBQsBAQEEBiMBBAEFAQoBAQErAQABAQEKAQEBCgIFAQsBCgEjASUCJAElAScICwIMARgBHwMmASgCJgQoAR8BKgEmASgBJgEMARgCHwEQBAsBCgEBAQQDAQIDAQADCgErAQUBAQEKAQECCgECAQQBCAEnASkBIwMpAgQBCgQLAhgBDAEYAR8BKgEsBAQBLAQjAgQDLAEtAh4FCwEKAQUBJwEBAwMBAAQKAgUBAAEKAQEDCgECAgQFIwIEAQoDCwEMAR8BGAQEBggCJwcIAgQBLAEOCQsCCgELAwoCBQIAAgEDCgEBAQUDJwMBAQgBAAEKAwsBFgEfAS4CAQMFBQACJwUAAQEBAAEKAgEBLgEMBwsBAAEnAQACCwIKAwUBAAEHAQEDCgEAAQUCAgMDAQEBCAEBAQoBCwEMARgBEAEoAgEBBQQAAQEGJwEpAScCAQMAAQoBJwEBAR8BDAYLAQABKQEBAQsDCgIFAgABAQEFAgoCCwIKBAUBAQEAAQoBCwIMAR8BGAEWAQoFAQInASUCJwElAScBKQEkAicDAQEAAgEBCgEWARgBDgULAQABIwEBBQoDBQEGAQUECgILBAoDCwIMARgBHwEmAR8BKAEFBAEBJwIkAScBJQEkAiUBJAInBQEBCgEmAh4BFgULAQIBKQEAAQsECgEFASsBBgEAARMECgELAQwDAAULARYBGAEfBCgBBQIBAicBJQEkASUFJAElAicDAQEKAigCHwEWAQwECwEDASkBAAELBAoBBQIrAgYDCgILAQwBAAEIAQEECwEMARYCHwUoAQoBAAEpCiQBJQInAQUBCgEmAygCHwEeAwsBDAEDASkBAAMLAgoBBQIAAgYDCgILARABAgEEAQADDQELAQwBHgEfASgBHwENAhABLwEDASMMJAElASMBJwEAARICDQERASgBHwEeAQsCDAEQAQEBBAEAAwsCCgEFAQEBAAIGBAoBCwEQAQEBMAEBAQwECwEeASYBKAEWAy4BCAEnDyQBJwEEAQUDLgEYASYBGAMLARABAQEwAQABCwQKAQUBAQEAAgYDCgELARABDAEBATABAQEMAg0BCwEQAR4BLgEEAQoBLgExAS4BCgEnASUBJAElCiQCJQInATIBLQIuAQoBLAEYAQsBDQEMARABAAECAQACDwMKAQUBBgEBAQYBEwYLAQEBCAEBAQwCCwENAQ4BHgEuASwBMwEUAjECLgEnASkCIwIlASMEJQEjAScBIwEnAy4BMQEuATQBCgEEAR4BCwEMAhABAAEDAQUDDwI0AQoBBQEBAQoBAAMLAgwBCwEBATABAAEMAgsBDwENARgBAAEBAQACCwIxAy4BMQguATEBLgExAi4BMQEuAR0BDQEKAgACEAELARABDgEAAQIBBQEPBBECBQEBAQoBBgILATUCDAELAQABAQEFAhECDwEOARgBCgEBAScCCwEPAREBCwEVAi4BMQIuAzEBLgExAS4BMQEuATEBCwEXAREBDQE1AQoBCAEAAhACDwEOAQUBAQEKAQ8BNgE0AgwBCwEKAQEBCgEFAQsBEAIMAREBNAEAAQEBBQEPATUBEQESAQ4BGAEeAQEBJwEAAQsCDQELARQBDwEbARUCEQEcATEBLQELARwBEQEVAREBFQEPAREBMwE0AQoBBQEnAQoBHgEQARIBDQEOAQUBAAEKAQ8CCwMMAQUBAQEKAQUBDwMRAgoDBQEKARIBIAENAQ4CHgEKAQEBAAEKARECDQEUAQ8BGwEUARUBEQEcARcBLQELAhEBFAEbARUBNQEXAREBCwIAAQUCGAERAQ4BEgIKAQACCgIGAREBDwEQAgUCCgELAg8BEgEFATcBCAIJAQUBCgESATgBGQEYAh8BCgEBAQUBCgMNARQCDwIUATMBFwEVAQsCEQEXARsBDQE1AREBCwEKAQUBAQEKAR4BEAEOAQ8BCwEFATkBOgEJATsCHAMLAQoBBQIKATwDEQYAAQoBDgEaARkBHwEYARYBDgEBAgABDwE0AQsDDwMUARcBFQE1ARQBDQEXARsBCwE1ATwBCgEFAQIBFgIZAiIBEQEKATICKwMGAQoDDwEKAQUCCgELAg8BEgIKAj0CCgErAREBGgE+AQ4BFgEfARYBCwEFAQMCCgILAg8BNQMUARUBCwERAQ0BEQELATwDCgEFAhgBHgEZASIBOAERAgUBCgE9AToBPAIKAQ8CNQELAQUBCwENARICGgM4AT8CCgE0AQ4BGgE4AT4BDgEeARYCHwEYAQwCAAIKAQsBDwELATUCFAEVAgsBEQELAwoBAAEKARgCHwEeARIBPgEaAhEBEgEKAQUBPQEiARkBGgEZAhIBDwIKAREBGQEaASIBIwE4ARoBQAJBARoCIgE4ASIBGAEfARYBHwEYARYBCgECAQEBCgULAhQBFQULAQoCJwEMAhgCHwEaATgBGgI4ASIBPgFCAUMBIAELAxkCEQILARoBGQEXASMBJAEjARoBGQIRAyICOAQfARgBHwEKAgECCgQLAQwBHAEVBQsBBQEEATABCwEYBB8BDgE+AzgBIgFCARICIwEaAxkBEQE1AQsBGQE4AUQCJQEkASMBPgEiBDgBQgIfAR4DHwEYAQoBAgEIAQUBCwE0ARsBNAEPAQsBHAEUAgsBRQILAQUBKQEEAQoBGAEWAR4DHwEZAi4BPgI4ASIBJQEkASMBIAE+AhkBCwE1ASIBIwUkASMBRgFAAkcBPgELATgBJgEfASYBGgEZAQoBCAEsAQoBBQEKAREBNAFIAREBCwEUARcBCwERAQ0BEQELAgUBBAEnAQoBGQEQARoBHwImAT4BEAEZAj4BIgElASQBJQEjAiIBGQEMAQsBGQEnBCQBJQEkASMDQAE+AUIBDAEWAR8BGgEZATUBAAEDAQgCBQMLATUBRQELARIBFwELAg0CCwEKAQUBAgEnAgoBFwE+AUIBIgE4AT4BEgM+AiUDJAEjATgBEQELAhkBIgEjASUEJAElA0ABQwIxASYCHwEaAScBIwIsAQUBCgIfBAsBEgEXAwsBDAEeAQoBBQEEAiwBAwEOAiIBHwEmAUABOAFAAT4BIwYkAjgCGQEiAQUBJwMlASQBJQEnASIBQwFBAT4BEgEaAh8BJgELAQQBCAEEAQgBCgIfARoBEQEZARIBCwEbARwBCwEOARgBHgEmARgBCgEnAwQBCgE+ASIBJgE+ARECQwE+AScCJQEkASUBJAEjAQoBPgEZAT4BGQEAAQQBCAUjAScCRwEaAjEBSQFAARIBCwEFAwEBCgIfAi4BSgEuAhIBFQEPAjgBHwEmAR8BCgEAAycBCgEZAS4BIgIxAT4BQAEpBiMBKQEAATgBPgEiAT4BCgEAAQcBAQEEAgMBCAEFAkMBIgELATEBQQEqATEBPgIKAQUBCgFJASoBMQYuBjEBKAFCAQoCBQEKARkBRwMuAQ4CQAEFAQEBAgIIAQQBAwEBAQoBQAEiAUcBGgMKAQUBAQIKAQABCgRDAgsBIgMxAi4BMQEZAUICGQIuAQ0CGQINAi4BCwEPATgBMQguARIBRwJAAQoBBQEAAQoCAQEKAQUBCgE4AT4BRwE+ARkBDQERAgoBSwE2ARIBGgJHASoBSQIxAUMBEQENAS4CMQEaATEBSQEqAUoBOAERAR8BKAIqAR8BOAFAA0kBGQE+BDECEQI+AkMBQAIZATQBEQIKAUUBDQESAj4BRwJDASIBPgIZAT4BIgFAAkMCOAImAUMDSQQqASgCJgQqAygBJgEqASgCKgExAygBSQIxASYBHwMmAUADQwFAASICGQEiAUACQwE+AREBRwFBC0MBHgEfASoBJgEqAiYBHwIoAiYBKgEoAioBHwImAigBJgFGAioBJgIoASYBKAIqAigBJgEfAhkCMQhDATgBDQELAg8EGgESARkBGgEPARkBGgE4ARkBEAoZARoBOAIaAQ4BOAEiAQ0BGQEQAQ4GGQQ4AhkBEQM4AQ8BGQM4ASICGQERAQ8CCwEKBQwEEAEMFRAEDQ4QAgwBEAkMAQs="),
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
};