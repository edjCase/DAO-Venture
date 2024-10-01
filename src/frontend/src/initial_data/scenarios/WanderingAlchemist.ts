import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "wandering_alchemist",
    name: "The Wandering Alchemist",
    description: "You stumble upon a wild-eyed alchemist, their hair frazzled and eyebrows slightly singed. Their pack bubbles and fizzes ominously, occasionally letting out small puffs of rainbow-colored smoke.",
    location: {
        zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    image: decodeBase64ToImage("YiAfIDA6NyIhIiIoJiUsLBwcHDdFPDVBOjBCOTtOQTpUSkNfUEdmVU1pWFN8YFmDaF6IZWWSb2WbcGyhdCczMC0vMFF2XVV6XpHEmicrKkNaSlJ0WFNzXkJdSg0NDliEYSwzL0RnUjg8OkdMTDA5NDIrNlp+YFJPREdpUjlCOzg4MzA1LlNKPkprU09rVUpnUUFSREdgTlpmUWZ0fz9PREpHQDpLPF1VRkpiT2hjUExkUkddTURVRmBZSWhlUh4hHkhsUVVwWU9qUz1KPzhGO0ZZSpOHZ09nUltzXFJqVUZTR0leTGF3Wl1xXDU4MjxNPlRZRkJVQzQ8M0lURVlwVEtNQD5JPUddSkNRQlJOQElRREFKPkZOQmBkTlZRREVKQE9NQkZKPgEAAQEBAgIDAQQBBQEEAQYBBwEGAQgCBgIJAQoBCQQKAQsBDAMNAg4BDwEQAREDEgITAxICEQEPAg4CDQILAgoBCQMGAQgBBgEEARQBFQECAQMCAAMCAQMBBQECAQUBAAIBARUCCAEGAQgBCQUKAwsDDQEWARcCDwIRARIDEwIYARIDEQIOAQ0DCwEKAgkBBgMIAQcCFAEEAhUBAgEFAQABBQIDAQUBAgEBAQIBGQEAAQgBBwMGBQoDGgMMAQ0BGwEcAhcCEQESAhMBEQETAhgCEwEPAxYBHAELAh0BGgEKBAkBBgEAARQBBAEBAwACAgEFARkBHgEFAQQBBQEAAQcBCAMJAgYCCQEKAgsCDAELAQ0CFgEXAR8BDwIRAxIBEwEQARgFEwESAREBFgIcAwsFCQIGASABBAEUAwABAgEVAQUBGQEeAQIBAQEeAQUBCAEJAQgCBgEIAwoBGgEKAgsBDQMOAg8DEQESARMBGAESBRMCGAITARIDHAENAQwCCwIKAQYBBwIIAgQBFAMAAQIBAwEVAQUBAgEFAQgBHgEFAggCBgIJAwoBCwEKAQsBDAEhBA4CEQISAxMEIgEjARUCEwEYAhIBDwEWAw0CCgMJAgEBJAEBAQQBBQEUAQMBAAECAQUBAgEAAgUBAQEFARUBCAEJAQoBCQEHAgkBGgELAQoBHQELASEBDQMOAQ8CEQETAhECGAEeAQUBAAECASUBBQQYARMBJgINARwBDAELARoBCgIGAQEBCAEBASQBBAECARQBAQEAAQIBBAIFAQICBQElAQIBAQEGAQcBBgEDAgkBCgEaAQoDCwEMAg4CDwERAhIEGAEeAQUBAAECAQMBBQQYARMBEQIOARwCCwEaAwoBCAEUAQEBBAEVAQUBFAEEAQIBFAIFAQEBAgEFASUBHgQGASQBJwEJAQsCCgELASgBFgEbAg4EEQMSAxgBHgEFAQMCFQEFBRgCEAEPAQ4BFgQLAR0BCQMBARkBBQEUAgIBFAEBAQUBBAEFARkBHgEBAggCBgEpASIBCwEdARoBHQIMARsBEAEOARcDEQETAREBEwQYAQUCKgEAAQUBFQUYARICEAEmARYBDQEaAR0CCgEGAQQBJAEEARUBAgEUARUBAgIBAh4BAwIFAQkBCgEJASQBBAEVAwoCIQIMASYBHwEQAhEBEAETARgBEwQYAQUBKwEFAQABFQEsAQIBBQUYAhMBFgEbAS0BGwEtAR0BCgEGAQEBFQECARUBAgEUAgIBAwIIAR4BBQECAQcCBgEgAQUBAgMKAQwBLQMMAQ0BFgQRARMBGAETAhgBFQEDAwIBIgEjASUCIgEjASUEGAIRAQ4CFwEbAwoBAAEBAQMBFQECAQQCFAEAARQBCAIFARUBAQEIAQMBBQEjAQEBCQEKASEBDAEWAg4BFgEbAxACEQESAhMBGAEFASMBIgIpAyIEIwECAQUDGAETAREBEAEbAi4CGwEKAgEBAwEBAQUBFAEBAQgBBQEAAQEBBQEDARkCBAIFAgEBBgEdASEBGwEtAhsBDgMfAxEDEwIYAQUCHgIpAR4BBQQeBhgBEgMQARYBGwENAQwBAAEVAQIBFQEAAQECBgIFARkBBQEAAQUBFQEDAgEBIAEaAQwCCwEbAS0BGwEOAx8BEAIRAxMFGAEFAR4BAgEeAQUDHgEiARUFGAIRARAEHwEMAQYBAgEiARkBAQEgAQYBCAEGAQQBAAEeAQUBAwEVAiABAgELASEBLwEtAhsBLQEWARsBHwURBBICGAETAx4BAAEYAQUBHgEFASUBHgUYARMDEAQfARsBCQIVARkBFQEUAQYBCAEGAQICBQEDAQABBQEgAQEBCwEhAQwBLwEhAS0BIQEWAhsBEAERARABEQESAREBEgMTBBgCHgECARgBAwMeARUFGAETARICEQMfAQ4BGwEaAQICFQEBAQQBCAEJAQYBAQEeAQUBAwEFARUBCQELAQwBLQEhARsBDgEfARsBEAEWARABEgIQAREBEAISAxMDGAECAh4BBQEYAR4BAAEeAQUBIgEZBBgBEwESAhEBHwIQAR8BFgEuAQUBGQEAARUBCAEdAQkBCAEGAgUBAwEAAQkBHQELAS4BLQEhAS4BEAEmARsBHwEWAhACEQIQARIBEwESBBgBAgElAQADHgECAh4BAgEiARkBBQMYARMCEgERAhABEQEfASYBLQEBAQABBQEZAQEBCgEJAQgBIAEFAgIBAQEwATECLQEuAS8BFgIQARsBHwERARACEQEQAhIEEwMYAQABIgECAR4BAAEeASMBBQEeAQIBKQEDASMBMgEVAxgCEgIQAx8BFgEVASoBBQECAQEBCgEJAQcBAwEVAQIBGQEaAR0BMQEuAS8BLQEbARcBJgEQARsBJgEQAxEBEgETAhICEwMYAQUCJQEVAR4BBQEYATMCHgEVASUBGQEiASMBIgIYARMBEgMRAhABHwEuATQBAgErAQUBIAIJAQYBAAICARkBNAEvARsBLwEuAR8BLgEWASYBEAEbAR8CEQEQAxIDEwQYAQMCHgEZAQUBHgEzAR4BGQEeAQUBHgECASIBFQElAxgCEQMQAR8BJgEoAS4BFQEZAQIBIAIJAQYBAAEFAQMBFQEJAR0BDAEhAS4DGwIRAS4BHwEQAREBEAETAREBEgQTAxgCAgEiARkBHgEFAR4BAgEeARkBJQE1AQIBGQIlAQADGAMRAh8BDgIuAQ0CGQEVAQkBNgEGAgABAgEqAQkBGgEdATEBLgEWAS4BGwIQARsBFwIQAREBEgERARIEEwIYAQUBAgEeASIBJQEFASIBBQEjAQUBGQIiAQABGQIlAQUEGAMQASYBDgEuARsBDQECARkBFQIGAQgBAgEAARkBKgEJARoBLwExAS8BLQEuAQ4CHwEtAQ4CEAESAREBEwESAxMDGAMCAQUBIgEFASUBIwEAARkBIgEjARUBIgQVAQUDGAIQAh8BFwEuAS0BDAEVAQIBBQEGAQgBAQEFAQIBGQEqATQCHQELAS8BGwEvARYCEAEuARcBHwESBhMDGAEeAQUDHgEFARUBHgIFARkCHgIFAQACBQEVAQMBEwESAREDHwIOAS8BLgEMARkBAgEVAQYBCAEUAgABKwE3ATABCgE4AS0BLgEbAi4BEAEfAS4BJgERAhMBEgQTBBgDHgEFAR4BIwEeASUBBQEeAQUBAAceAQUBEwISAh8BFwEWAS8BLgEvARUBKgEVAggBAQEFAQABGQE5ATABCgEvAToBLgEcAS0BFwIfAS4BFwERBBIDEwQYBR4BFQEeAQICHgEZAQABAwEFAR4CBQECAR4CEgERARABHwEmARcBGwE7ATgBMQEqARUBGQIIAQEBBQEAASsBNwEJAQoBDAE6AQsBLQEuARcBDgIbARcBEAIRARIDEwUYAR4BBQIeAQUBGQEeATMBHgElAQICFQECAR4BAAEDASUBBQMRAh8BJgEXAS4BGgIdAxkCCAEBAR4BGQErATUBKgEJARoBPAE4ARsBLQIXASYBGwEXARABEQISAxMFGAEAASUCHgEFARkBBQEZAQABJQECAhUBAgIFAiUBFQERAhABHwEmAhcBLgE8AQsBHQEkAhkCCAEBAQUBHgEZARUBKgIKAh0DGwIXAhsBEAIRAhICEwQYASUBBQEDAh4BBQEZAR4BBQEeASUBAgIlAQICHgEZASUBBQIPAR8BJgEWARsBLgEtATwBCwEdARUBKwECAggBBwEFAR4BBQEZASoBCQEaAQsBGgExAS0CGwEmARsBFwEfAhABEQQTAxgBBQECAQUCHgEFARkBHgECAQUBJQEZASUBFQECAQUBHgEFASIBIwEZAh8BJgEWARsBLgExATACCQIVAQIBAQIkAQIBBQECASsBLAEHATABGgEdAjEBLwEbARcBGwEXASYCEAERAhICEwMYAgUBAAIeAQUBAwEFAh4BJQEVAiUBAAIeAiIBFQEeASYBFwEbAi0BGwEdATwCCQECASsBAgEBASQBBAEDAQUCGQE9AQcBNAEwARoBMQEvATEBLwEbAS0BFgEmARABEQEQARIDEwIYAQUCKQMeAQIBAAMeARkBFQElAQIBIwMFAQIBHgERASYBFwEWAS4BGgELATsBGgEKAQkBGQEVAQIBAQEUASABGQEFAQABFQE3ASIBNAEJATQBHQExAS8BMQEvAS4BFwEfARACEQESAxMDGAEeAQUDHgECAQACHgICAiUBAAEVAR4BIwINASIBDwEmARcBHAEuAjEBOwIaATQBGQEAAQIBFAEEARQBGQEeAQABGQEsASoBCQE0AQoBHQExAi8BLQEuARcCEAIRARIEEwIYAQABHgERAR4BBQIAAh4BAgElARUBJQECAQUBHgEVAQMBHgElAhcDLgEMAS8BHQIaAQkBGQEFAQICBAIUAR4BAAECAioBCQE0AxoBMQEtAS4BOAEbAiYCEAESBRMBAAEsAQABPgEeAQUCAAMeASUBAAEVARkBAgEFAT8BHgEiAR4CJgEbAS4CLwE7AjwBCQEHAQIBBQEABBQBHgEFAQIBFQEqATQDMAEdATgBLQIvATgBLgEfARABHwEQARIEEwEeAT4BGAIeAQUCAgEFAh4BJQECARUBIAE/AUABBQEeAQUBEAEmARcCLgE4ATEBGgIJAQYBJAEVAQABGQQUAQUBGQEFARkBNQIJATQBCQEwAR0BLQFBAS8BLQEbARcBHwEQAR8BEQMTAR4BEwEFAR4BEQEeAQUCAgEeAQABHgElAQMBBwEDAQgBEwEIAgUBDwEXARwBFwE6ATwBMAIJAQcBAQEVAgIDFAEgARkBBQEZAQIBGQEqATYBCQI7ATABOwExATgBLwIuARsBDwEQAhECEwErASwBAgE3AgUBHgEFAQABAgEeAQUBHgEZATsBJAEDARIBGAESAT8BHgEPASYBQgE4AhoCMAE0AUMBBwEZAQMBBAMUASABKQEVAR4BAgEVARkBBgEHAUQBCQFFARoBMQEvAS4CGwEmARsCHwIRASoBOQJGATkBKgECAR4BBQEAAQUBHgEiAR4BAgE7ASQBAwEIARIBCAIeASYBEAENAToBRQE8ARoBPAE0AgcBGQUUAgQBAwEeAQICGQEHAUQBNAE8AQkBGgExAS8BOgFCAUcCGwEXARACEQEZAQABKgEeATcBKgECAwUCHgEiAgUBFQEBAQUBPwEIAx4BJQEQAUgBSQE4ATsBSgMwAQgBBgEIASQDFAEFAQQBFAEeAQUBGQEqAQMBNAFLATQBMAEaATsBLgFBARsBLgFHARsCJgERARABBQEqASwBAgErASwBKwEeAQUBAAEeAQUBJQEAAR4BFQErAQIBBQQeAQUCSAFJATgBOwE8AUUBCQE2AUMBNgIkAxQBAwIEAQMBHgECASsBGQEHAQkBQwEaATEBOAFHATEBSAEXARsBJgEbAR8CEQEAAQIBNwEFATkBNwErAQACBQEeASUBBQIeATUBFQECAQUDHgIFASYCTAFNATIBSwEwAgkBBgMIASQBFAEEARkBIAEDAQQBHgEFARUBKgEVAQkBNAEJATwBMAE8ATEBOgFCARcBGwEmAR8CEAECAQUBAgEFASoBAgEAAR4BAgIeAQIDHgEiARUCAgEFAh4CBQEeBEwBMgE4ATsCNgFEASQBIAEkAgQBAwIEAQUCHgECASMBTgFDAQkBMAE0AT0BGgFBAUcBGwEuAhcCEAERAR4BBQECAQUBKgECAR4CBQMeARkBBQEeASIDGQIFAx4BAANGAUwBTQFFATABNgEHAgEBIAEUAQQBFAEDAgQBGQEDAgUBAgIiATQBCQEHATACGgI4AUcCLgEmAxAEEQEeAQUBAgQeARkCHgEiAQIBGQMFBR4DRgE+ATgBSwE0AUMBBgEIASABFAEkARQBAwEVARkBAwEZAQQBFQEFARkBIwE2AQkBTwFEATABLgEaAUUBOAEuAToBGwEQARcBEAERARABEQIeAgUEHgElAh4BIgEAARkBAAIFAR4BRgMeASoBRgJMAUcCNAE2AQYBJAEgARQCAwEZAQMBFQEDAQQBAwEAAQIBBQEZASsCPAEGAUUBMAEaATgBMQE4ATsBLwEbASYEEAEeAQUBAgUeAQACHgEjAQIBGQMFB0YBTAFQAVEBNAE2A1IBFAEEASQBHgEZASQBBwEDARkBIAEkAQcCAgE1ASoBRAE8ATIBMAFFAjwBSQFBAUkBRwEbASYDEAEeAgUCHgImAR4BAgIeASUBAgEDAQUCHgZGAUwCMgFPATABCAFPATYCFAEEAQABHgICAQMBGQEgASQBCAIgAQcBFQEqARUBUgE0AQYBCQE4AUkBRQE4AUgBLgIbARACJgEPAQABBQEeARACEQEeAQICHgEVAgACHgVGAUwBPgFQATIBUwFDAVIBCAEgARQBJAEUAU4BFQMDARkBRAEHASsBCQFRAR0BBgJEAQgBNgE0AQkBGgE8ATABRQFMAUIBGwFCARcBEAFBAUgCEAEeAxECRgECAh4BFQEAAR4BBQJGAUwCRgE+AUwBMgFLAUoBKQEkAQgBFAEgAQgBGQEEAT8BAAEFAQIBGQEUAVIBBAEDASABGQErAUQBAQFEAQkBCAEJAUUBQQE4ATwBOgFLATgBQQEmAUEBSQFBAU0CTAIRBEYBGQEeASMBAgEeBkYCOQE9ATwBUAFDAQEBBwEZASQBAwECASABAgEkARkBHgEgAQUBFAECAgMBGQEgARkBJAE2AUQBCAI0AjABTwE8ATQBRQE7AUcBSQFUAUkCMgFMB0YCHgElARUBHgRGAj4BOQFVATUBPAFWAiABGQEgAQIBGQEkARkBIAEDAQUBHgMFAQIBNgFXAk8BJAEZAiABBwFPATYBNAEHAVgBUAE0AUoBOgE4AU0DPghGAz4DHgM+AzcBWQFVASoBOAE0ARkCIAEVAgICBAIFAQIBHgEFAQIBKwEFAQIBGQIrAU8BCAEkASsBJAEHAikBRAFaAVABWwFcAVABXQI+AUwFRgE+AV4COQI+AQUBAgIeATUBNwFeATUBLAInAVwBQwFSASQBCQE0ATYDGQE/AQMBAgIAAR4BBQEiAQUDAgEEAiABGQFfASkBCQEHAUQBJwFbAloBYAFeAV0BPgNGAT4BNwE5ATcBPQE3ASkBKgE1AyoBIgEeARUBIgI1AioBWwEpAQQBGQEEAQgBLwEIAUQBIAEEARkBAQIDAQUBIAEeAQUBGQIgARUBIAFSASABCAFSASABKwEkAVIBNQFZAVYBNQEnAT0BOQVGASwBNQEiBTUDKgEFASUBAAUqATUCUgE2ASQBIAEEARkBIAEIAiQBBwEDASABBQECAR4BAwEFARkBPwEAAQIBIAIDASACKwIkASIBVgFhAVoBXgE9Az4ERgE3BDUGKgEjARkBHgEVASoCLAI1AVsBFAIDAQgBTwEkASsCIAEZAQMBBAEGAiQBBQEeAgUBBAEgAQEBGQEiARUBGQEgASkBBwEpAVUBKQFeATcCOQE+ATkCPgE5AT4BPQE5AT4BOQE+AjkBNwE9ATUBKwEFAh4BAgM1AlYBJAEUAQQBJAEgARkEAwICAgMBAAEFAgIBHgMFARkBAwEgASkBXwEVAiIBKQI1AV4BOQI+ATkBPgNGAT4BNwQ5AV4DOQEsAyoBGQEqAiwBYQEqAU4BJAEHASkDJAIZAgACBQEVAgUBHgECAR4BBQEeAwUBFQEZASkBGQEVASsCKgE1ATcBLAE5ATcCPgE3ATkCPgE3AV4DOQFeAzkBPgFeAj0BXgI3AV4BLAE1ASoCWwEkARkCIwEGAikBAQIUAQQBBQECAQUBHgEFAh4GBQcqAV4BNQE3ASwBOQM+ATkCNwE5Aj0BXgI9ATkBPgEsAjcBPQI5ASwBXgEsASoBIgE1ASICKQEiARkBAAEFAgIEAAYFAR4FBQEVASoBAgQqATUDLAE1ASwBPQE3BCwBNwE9ASwBNwI9ATUBNwMsAV4BLAE1AiwBKgErASoBKwEgASsBYQEqAQUBHhAF"),
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
                            description: "Politely decline and leave the alchemist to their experiments.",
                            requirement: [],
                            effects: [],
                            nextPath: { none: null }
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
};