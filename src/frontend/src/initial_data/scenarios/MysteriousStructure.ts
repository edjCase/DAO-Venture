import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData =
{
    id: "mysterious_structure",
    name: "Mysterious Structure",
    description: "You encounter a pyramid-like structure with glowing runes, overgrown by vines. A sealed entrance beckons. It's either an ancient temple or the world's most elaborate garden shed.",
    location: {
        // zoneIds: ["ancient_ruins"], TODO
        common: null
    },
    category: { "other": null },
    image: decodeBase64ToImage("Yg4SIxQzRBY4PxM2PRU0QBc7SxIfMg8uOBApNhMpLRQ5OhlJRhpHNhg7NRtLNRY/QBYpPQ8cLBY8OBc9NBAlMQ8WLBZSSRc1SA8iKxEcLA4cMwsTKxIsQh9dThxZMhlOSB1ONhIhKRlASS1eVBxARx5FUhtBTw4dPw8XNHLdm3TamSRWUCVXWBc0TCBKVChcWBIsUBU7chtEZidhZVOzeyhdXyVRWC+McRErVBM5UhhPXzJoZCVXWxIsURMxaSlhaCROUA8hRRMrXxElTQ4qZxA2hz6FahInVQV99wS6+Rg7PjZxbBQ1eApFvZLgjSpaVQ8lThAshBIvfw4aPwpKmxdDYSRKTh1IXRx4kBFXdhE7UiBeZSpyfx86OB5eZyBRaCJIUx44QwsAAQECAgMDAQIBAwEEAgMBBAEDAwQCAwMEAgMBBAIDAwQBAwEBAgQCAwICBAUBAhAAAQYCAAEHAQgBBwEJAQoBCwEHAQwBDQEOAQMBBAMBAgQBAwEEAwMBAQEDAQQBAwEEAQMDBAIBAgQDAwELAQ8BAgEHAQgCAwEHAgABBgoAARABCAERAQgBBwEAAREBDwECAQkBEgEDARMCDwEJAQQDAQEEBAMBBAEDAQQCBQIEAQEEBAEBAQQBAwECAgMCCgEJAQoBCAIPAQkCCAERAgcHAAEUAgABEAEVAQABBgEHAQABCAEKAQcBCwEOARYBBwEKBQEBBAcBAQQBAQEXBgEBBAMCAQMBBwIPAwkBGAEDARgBCAEUARkBAAERAQABGgEbAwACFQEAARoBEQEVARwBCAEHAQABGAEAAQkBDAEHARIBHQEeAQMFAQEXDgEBAgEPAR8BIAEJAQ4BGAEUAQMBEQEAARgBCAIAAREBBgIAARkEAAEIAQcBAAEZAhUBBgEVAgABBgEHAg8BCQEgAR0BIAEeAR0CDwEDBwUCAQcFAg8BDQEJARIBCgEHAgABFAEAARECAAEQAgABFQIIAQABGgQAARkBAAIRAQgBFQEIAQQBBgEAAREBDwEhAQcBCQETAQwCIAELAiIMBQECAQUCDwEdAh8BCwEJARgBCAIHAREBHAIHARQBAAEYAggBAAERAQgDAAEGARABEQIVARkBAAEHAQEBFAIPAQkBCwIKAQwBHQEeARMBHQIfAiINBQEiAR0CDwEKAQ8BDQIKARQBCAEZAQABGgIAAgYBCAEGARUCEQEVAwABGgIVARACCAIAARkBFAERAQcBCQEWAR0BEwEdAiMBCwEkAQsCIgQFASUBJgQiAgUBAgMiAR0BHwEKARYBCQIAAQcCCAIcAQgBAAEnAwABCAIAARUBAAEoAgABFQERAQABFQIaARQBCwEfAQsBDwEWARIDFgIdAyUBDwELAikBKgcpAQ8BHwImAQsBHwETARYCCgEJARQBBwEZBQABFQEAAQYBCAEAARoBFQIAAhUBAAEVAQYBGQQAARkBIQEKAh8BKwEsASsBHQErAR8BJQIfBCoCKQEqAS0GKQEiAiYBJQEfAR0BIwESAQsBFAEPASUBLgErAQsBFQEAARsBAAEaAhUBGgMAAScCAAIVARoBBgEEAQ8BAwIPAQcBCwMvASwBLwErAi4CKQQqAikBMAExATIGKQEzAQsCLgErAR0BHwELARQBAwElAS4BNAEqAjQBAAEaAQABFQEaAQABGgQAASgBFQEZAQABJAEiAQ8BIgEuASwBAAESAS8BNQMsASsBNgE3ASkGKgEcATgBOQEcATICKQEqASkCKgE0Bi4BOgEuATsBKwE0AyoCAAIVAQACFQMAARUBAAEbARUBAwEKASoBOwI8AS4BFAIsAzwBNgEsATQEKgQpATABEAE9AT4BMAE/AikEKgE0Ai4BNgIuAiwBKQUqAS4BFQIAAQYBGgMAASgBFQEaARUBFAUqAS8BLAEUAUABPAEsAUABPAE3AioBKQMqAykBQQE4AUEBQgEwATgBQwEqASkCKgEpAyoBLgM2ASwBNAUqAg8BIgIZAQABFQQAARoCGQERAQkBDwMqATQBDwEDASYBNgI8ASwBLwMqBSkBLQIwAkEBHAE4AkICKQEqASkDKgE0AS4BLAEvBioCHwEPASIBDwEGAgABKAMAAhUBBgEZAQIBAwEdAyoBLAELAS4BNgI8ASwCKgEpASoFKQFBAUMBGgFEAUUBRAEnATgBMAE/AykDKgE0ATUBLwcqAR8BCwEiAQ8BIgEIAQYEAAEGARwBJwERARABAwEiAQsBOwQqAS4BNgJGAyoBKQMqATQBKgE+ATgBGgFHA0gBRAEwAj0BKgIpASoDKQE7ATQFKgEKAQkBOwE0AioHAAEGARwBAAEVAgABCgEfAS8GKgI0BCoEKQEIAUMCPQFFA0kBQgFDATgBPQE+ASoBKQIqBCkDKgErAQkBLAEJBAABNAEVAQABGgMAAQYBGgIAARUBGQEPAQkBLwgqAykBKgQpAgYBQwEnARsBKAFEASgBGwEaAUMBHAEwAQYBKQMqAikBHQE3ASMBCgILAUYBNAEfAUYBNAEqAUYBKgEZAQABFQIAARoBAAEnARkBSgFGAUsBKgE0BCoBKQUqBCkBKgE5Aj4BMQFMAUUDTQNMAT4CQgIqASkCKgE3ATQBHQE3AR0BCQELAgkBOwNOASoBTgFGARUFAAEZAQ8BSwQqATcBKgE7ATcBTwE0ASoBKQEqBSkBEAQAARUJAAEaAUIDKQIqASkBKgE3AS8BDwEiATMBRgEfAR0BDQNOATsBGQQAARoBBgEkAR0BOwEqASMBKgE1AR0BKgEdASoBHQEqBikCEAE9AzABQgFHAUUCTQJCAjgBPQEwATkBGQUpASoCNwEzAUsCOwJGBE4BHwE0ARUCAAEZAQgBDwE2AjQBOwE0ATcBKgI3ASoBHQEqASkBKgUpAT4COAFCATgBPQEwAUECRAFFAUIBPQY4ATQBKQEqAikCKgM0AjsBRgEqATQBOwEjAk4BNAEVAgABJwEGAQ8BLgMqATQCKgE7ASoBKQEqAUYGKQEZAhoBKAEAAUEBFQEnAUUCSQFIAUQBQQEnAQAEFQEAATQDKQIqASkBOwE3ASsBSwIqATQBOwROAwABJwEIASIBLgIqATcBHQFLAR0CKgQpATQDKQEQAhwCQwEaAUIBJwFCAUUDSQFFARoBQgEVAUMBRwFDATgBMAEGBikCKgE0ASoBOwEqAS8FTgMAAUEBEAEiAQsBNAEzAS8BCgEPAS8BRgM0ASoCNAIpARwFQQEaAUIBJwFDAVABUQFCAVIBQQEoAUIBJwFBAUMBOAJDAkIHKQE3AjQBRgEjAjQCTgEjAwABQQEQAQMBNwE0AUYBNAEsAQ8INAEqAQYDAAEVAgABOAEwAUMBQQFFAkgBTQEoAUEBMAEaAUEFFQEAAzQDKQI0ATcBNAFGATcDNAJOAwABGQEGAQMBKwE3AioBMwFLCTQBFQEoAhoBUwEaARUBHAFHAUMBRwFUA0kBRAFHATABFQFBAQABJwEAAUEBGgFDAQYENAEpASoENwFLAS8CNwErAR0DAAEnAQYBAwEiASsBSwE2ATsBSwI3BjQBMAE+AUwBQgM+ARoBAQFDAUEBRAFSAUgBSQFIAUQBRwIVARwBBgE+BEwBMQFVAzQFNwFLATMBLwEfAQ8BLwFAAwABJwEIAQcBDwEkARYBAwEzAR8DNwQ0ARADKAIAARUBAAEVAT0BFQFBARkCKAJQAVMBQQE9ARUBPQEABBsBFQIAATcENAI3AS8BCwFKAR8BSwEKAgsDAAEnAggBAwELAQ8BBwEvAR8BDwE7AzcBNAEcARoBJwMoAQABGgEAARUBMAEAAUEBQgJUAk0BRAEnAUIBFQEcASgBQQEAAUEBAAEoAQACGgQ0BDcBVgECAQ8BHQEsAS4DAAEZAQIBCgEJAgMBBwIfATcBHwQ3AUMBQgE+ATEBFQNMAUEBJwE4AQABQgE+AUgCSQFIAUUBRwE9AQYBPQEnAT4CTAE+BEwBMQESBzcBLwEkAS8CAgMAARUBAwEPAUoCBwEDAUoBKwE3AR8BLwI3AQYJAAEGARwBGgEwAUwESQFUAUEBFQEGARwIAAEbAQABKwI3AkYCNwFGATsBDQECAQgBAwMAAgYBSgEPAgMBCQECAR8CHQEvAR0BKwMoARUCKAEAASgBAAEVAQgBOQEAAkIBVAFFAVQBRQFEAUIBOQEAARwBAAEVAQADKAMAASgBFQY3ATsBSwEEAQgCBwMAARUCBwIDAgcBIgEkAR8BHQEvAR0BGgEnAQABKAEVAigBAAEoAQABFQEwAUMBFQEcAScEGwEVAUMBQgEAARwBAAEoAQABJwEAASgCAAEVAUEBGgE5AzcBSwEkAg8BBAEHAQEBCQMAARkBFAECAQgBAwIHAQIBDwIWARIBVwE+BkwCPgE4AUEBMAFBAScBQgEaAU0CSQFIAVEBQwFCAScBQgEGAT4BQgFMAUUBTAJFAUcBTAJCAT4DNwEkAQ8CBAMHAwACBwECARACBwIDAg8BCwEVASgBFQIoBQABFQIAAUEBFQEnATgBRwFIA0kBUQFDARABJwEcAQABKAEAARUBKAIVAwABKAIVATcBOwEfAkoBBAIDAQgBGAMAARkBFAIEAggBAwEPAQICCwEZATgBPQEoAScBAAEnAVMBAAIoAQABKAEnAVMBQgEoAUEESQFSAUIBPgIGAQABQwEoAScBRwEAASgBAAFHAUEBTAI+ATEDDwFKASYCBAEIAQcEAAEYAQMBBQEUARICFgIPAScBUwIoAScBUwE+AUQBRwNCAUEBEAEVAUEBPgFBAUIESQFNAUIBPgEoATgBBgFCAVABRwFCAUEBQwFBBQABGwEAAQsBDwIiAQICAQEGARECAAFKARgBBwEUAQgBGAEKAg8BBwEVAVMDKAEAAT4BAAEoARoBAAEVAQABHAEVAScBQgFDAUQBSANJAU0CQgEAATgCAAIoAUIBKAFDATgFAAEVARsBAwELAQ0BCgEJAQQCCAMAAggBBwESASABHwEhAQoBBAEQAT4BQgU+A0wBPgFCARoBOAEVAUMBQgFDAT4ESQFIAkIBFQFDASgBJwFDAT4BRQFDATECTAJFA0wCMQEKAR8CDwEhAQgBEQEGAgABEQEHARgBEQIJAgMBBwIAARUBKAMAARUBKAEAASgBAAEoAREBBgEAAUMBPgFDATgESQFIAUwBQgEoAUMBAAEVAQABFQEAASgBAAIbAwABFQEAAhUBGAEHARkBFAEGAggBHAMAARgBGQEIASEBFAIAARUBQQEAAVMBQQEAARsBAAEoARoBAAFTAQABKAIGAQABQQE4AUMBRQRJAUgBRwFBASgBQQMVAVMBKAEnASgCAAFTAQABQQEnAQABKAEAAScBGQEGARkBCAEBAQABFQIAARQBDAEUARUBFAEhAQABJwE+BUwGRQFMATEBQgFBARUCPQFBAUMBVAFIAU0CSAFMATgBGgEnAVMBPgIxBUwGRQJMARwBBwEEAhkBCAMAAQMBEQEHAhkCJwYAAUIBRQEoAhUBAAEoAVMBAAERAUMBAAEQAUMBQQE+AVQBSAJFAVIBPgFCARoBQQEAAUECAAEVAwABQwFQASgBFQIoAQADFQIAAQYBBwEVAQgCAAEaAQYBGQEAAQcCAAIoAQABGgEAASgBSAFJAUEBAAFCAQABRwEAARUBEAEaAQACFQFHASgBRAFSAVQBRAFTAUcBGgInAQABQQEAAigBFQEoAQABRAFJAVQBKAEAAUEBLQEAAygBAAEUAhUEAAIcARkBAAEaARUCKAEaAQACKAFEAUcBJwEVAVMBRQEVAQABQQEaAgABGgEVAUMBPgFUA0gBRQFBAUICGgEAARoBFQEoAQABGgFBAQABQQFHAUIBAAFTAT4BPQEVAQABKAIAAgcBBAEVARsBAAEaARUBEQFBATgBQgEcBT4BTAE+AkUFVAdYBUkCSAhYAVQDWQJFAjEBPgExAj4BMQM+ARkBAAEZAwABHAEAARoBEQEaARAGAAIVAwACGwIVAhsBAAEnAxUBGwMoAxsBHAEVAwACFQEaAgABFQEbARUDAAEIARUBAAEUAQABBgEVARwDBgEAAScBGQEAARcBHQEfARYBDwEvASMBFwFaAQABFAEAAREBAAEVBAABFQEAARABFwFYAUgGSQFIAU0BPgEtARUBGgEHAhUBAAEVAicBGwEoAhwBEAEAAQEBMwEPAR8BWwEJARUBAAEQAwABFAIGAQEBFwE6ARYBBAEAARUBGQEEARQBIAEYASABFQEbAxUBHQEZAQABLgEABRsBKAIbARoBAAEQAQACCAEVAQsBCQFbAQsBBgEBAQYBHwIWAVsBSgEZAREBFQEFAR8BLgElAQgCAAEZAVoBJQEmAQgBBgEQAQQBFgEIAQACBgIMAQ4BHQESAR4BEgE3AQ4BHgEOAQkCXAJYBEkBSAJYAVwBJgEBAR4BAAEMAQABXQEfAQ8BCAIXAR8BWwEfAToBLgEGARwBBgEBAQUBAQEEAwABEAEXAQgBAAEGATkBBQEBASIBFgEdAV4BEwEgAQwBDgETASABDAEdAR4BFAEHAh4BXAVYAUgDWAJcARcDHgEgARMBHgEMAQkBDAEIARkBEAEUAQMBCwEPARwBJgEcATkBAAEVARoBCAIAAScBBgERARABFwEZAQcBAwELAQcBCwIWAQoBDAENASABHgEgARgBHgETASABHgERARABBgEQAVgBXAFVAV8CXAEmAQYBFwEhAR4BRgEdAh4BIAEeASACEwIWAR0BFgEPASYBDwEHAQMBAAERAgUGAAEBARUBBwEFAQgBOgEPASIBHwE6AS4BFgEOAR8BHQEfAQsCHgEdAR4BJgJcAT8BBgEVAhQDFQFcAUsBLwIWAR4BHQEeASABHgIgAQ4BHwEHAQMBAgEQAQABCAIlARkBEQEHAQABBgEVAgABBwEIAgABBgEAAQEBOgEuAREBBwEDAVoBEAEOAQ0BHwEWASADHgEgAlwBXwhcAS4CMwEGBR4BHQEOAiABDAEPASIBJQEXAQgBAQFaAQUBCAEAARACCAMAAREBFQEUAQYBFwEUARkBDwEEASYCCwEAARABCQECAQsBFgEIASABHgETAQABHAEVARcCFQEGARUBCAEGARcBGwEQAgABBwEdAx4BGQEXARQBJQICAQYBGQI6ASYBIQEAAQcBBAEVAREBHAEIBAABAQEXAxwBBgEHASIBDwELAQYBEAEZAS4COgEgAQwCHQEMAQ0BXwFZATYCPAE1AjMBPwEzAT8BNgFbATwBDAESAQ0BHgEMARMBBwFKARkBBwEiARABAAEUAQEBGQEEAQgBAAEIAVoBFwEAARkDAAEVARABAAIIARECBQERAQABBgEAAR8BCwEKASYBBAEgAQ4BEwEgAQwBFAEQAREBAAIGAQECGQEGAgABEAEAARABFQEHAQsBDQETASABCgEJAQgBAAEQAS0BCAEAAREBGQEIARQBAAERARwBEQIUAwABKAEVAREBAAEVAQgBJgEQAREBCAEBARwBAwECAQ8BGQEYAQoBEgEgAgoBAwJWAi4BPAE2ARABGgFWAzYBYAElASYBGQFKARIBDgITAQcBGgEEASEBFQEJARkBHAIBAhEBCAERARQBGQYAARQBAAEVARABCAEVAQABFAERARoBAAIIAQABFAEDAQcBSgECAQgBBgMkAWECGgEGARwBBgEaAQQBGgFgASUBJAEUAggBCgEOAQwBFAEGARUCGgEIARkBLQIGAQABGwEVAQABJwEGFQACGQIAARoDYQQkBCYBYAEkAmEBFwEVAREBAAEVVAA="),
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
};