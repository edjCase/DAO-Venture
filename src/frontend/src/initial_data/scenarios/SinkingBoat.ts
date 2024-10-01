import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData =
{
    id: "sinking_boat",
    name: "Sinking Boat",
    description: "You come across a small boat sinking in a nearby river. The passengers are calling for help, their cries punctuated by the occasional glub-glub of the boat.",
    location: {
        zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    image: decodeBase64ToImage("Qz9GPi4+Oi9FNTdINN3cy93bydzbyXWvpH62qi8zNkJkXLrBsMjRyCgoK0MyLkApKTA6RlNEPF5ORG5CLVIvKFmFd0VdNEtsZEpqXFFcUEptZkx0aVyGeNbVwUlpZFJ4bFSBdIBmU3GWh1h9bW2YiW+nmmWNfWCRh16Ne5OIdlpURFNdUYalm3KsnnScl2qdkE5zW2CIemmek0RqW2KXiWqjmWeej1V5ZlJyYVRoXluUg2dnV2eTiFJ1YWKRfWKWh2mYh2+aj1uLdwIAAQECAgEAAgIBAAICAQABAwcEDAUBBAEFAQYGBQIEAgUDBAEFAQQBBQQEAQcBAgEIAQEBAgEJAgIBAQEAAwEBAwEAAgEFAgEKAwQCBQEEBwUBBAEFAQQHBQIEAgUBBAIFBQQCBQQEAQkDAQICAQADAgEDAQkCAgEJAQEBAgEBAQIBAQECAQABAwIEAQYBBAMFAQQNBQEEAgUBBAQFAQQBBQIEAgUBBAMFAQQBAAEBAQICAQQCAQMBCQQCAgkBAgEAAQIBCQICAQMBAAIEAQUDBAEFAgQdBQEGAQkGAgEBAgIBAQEJAgEBAgMBBgIBAwEEAQYCBQEEAQUCBBQFAQQEBQUEBAEBAAEJAgEBAgIJAQEBAwEAAQEBAgEBAQMCAQICAQkCAgIKAQQBBgYFAQQBBQEGCAUIBgcFAQQBBQEGAQkBAQEJAwEBAAICAQABAQEJAQIBAQECAgkBAgEDAQECCQMBAQMBAAELAQQDBgYFAQYBBAQGAgUBBgELBQwJBgIEAQkBAgEJAQEBCQMBAQkCAQEJAwEBDQEJAwEBCQMBAwIBCAQMAQYBBAEGAgUCBgMMAgQDBgELBQwDBgYMAQQCAQECAQEBDQIJAQ0CCQEBAQ0CCQEOAg8BDgEJAgIDCQIBAgIBAwEIBQwBBAQGBAwBCwEMAQsBBAYMAQsBBAEGBgwBCwEQAwEBDgENAQ4CCQEOAQEBDwENAQ8BDgENAQkBEQMJAREBDQEBAQkEAgUIAQwBCwIIAgsEDAELAggIDAQLAQgDCwEMAQABAQENAQkBEQEJAQ4BCQIOAQ0BDgENAREBDwEOAQkBDgMNARIBDQEBAQkDAQECDAgBCwYIAQsCDAELBAgBCwcIAQEDDQETAQkBDgEJAREBFAENARQBDQEOAQ8BDgEJAQ4BCQINAREBDQEJAg0BAgEJFQgCCwwIAQIBCQMBARQBAQECAQEBDgEUAQkBEQIJAQICCQICAQEBAgMBAQMCAQECAQEBAh4IARUBAAEDAwIBAQQCAgEBAwEBAQ8BAgIDAQEBAwICAQMBAgEDBAICAwMCGggBCgEBAQIBAAECARYBAwECAwMBAgIDAQEBAgEDAQIBAwICAgMCAgEDAQIBAwECCwMCFgECAQAIBgUMAgYDBAEDAwICAwEWAQMBAgEWAgIDAwICARYBAgEDAQIBAQMAAgEBAgEDAQICAwUAAQMIAAEKAQIBBAEFAQYDBQQGAQQCBgEEARcBGAEBAQMBGQEAAQMFFgIABQMBAgEDAQIBCQcaAhsDGgUbARwCDAEGAQQBBgEEAR0BBAEdAgQIBQMGAQwDBAEMAQYCBAIeAxoBHgQXARoCFwMaARsBHwYbAR8CGwMfAhsBIAEEAgYBBQEGAQUCBgEhAwQJBQIGAQQBBgIEAQYCBQEGAQwBBgIMDhsCHwEbAR8BGwEfBhsBGgEbASABBAEFAwYBBAEFASEBBgEEBgUBBAYFAQYBBAIGAQQEBQEEAQUBBAEeAhsDHwEbAh8DGwMfARsCHwMbAR8HGwEEAgUBBgIFAQQBCgEIAQ8BIgEFAQQOBQEEAgUBBgMEAQUBBgMbAh8BGwEfBBsBHwUbAR8GGwEaAR8BDAIEAgYBBAIFAQQBCQEIAiEBBQIEDAUBBAIFAQQBBgEFAQQBBQIGAQwBGgkbAh8KGwEfASABGwIEAgUDBAIFAQEBIAEUASEBDAEGAQQJBQIEAQUBBAEFAQQBBQEGAgUBBAIFAQYBHgkbBB8BGwIfASMCHwEkASIDBAIFAgQEBgIEAQ0CIQEgAQsBBAEGAQQIBQEEAgUBBAkFAgQBJQIbAx8CGwkgAQsBDAMGAwUDBgQMASEBCQIhAQ0BCwMEAQYOBQIEBQUCBAEbBCACHwEgASYBJwEoAScCCwEgASgDCwEEBAUBBgEEAQ8FFAEQAyEDEwIpAQQGBgUFAQYDBAIFAQQBBgIFAQQBGgEMAQQBHAEoAQgBDAILAgwICwEEBQUCIQIUARMCFAIJASABHgUPARQCEwMMAQYBBAQFAQYBBQIEAQYCBQEEAQYBBAIFAwQBDAEEAQwMCwQGAgQBDwETASEBFAEJAQ0CCQENAQoBGwENAQ8BFAUPAhQCEwERBgYBBAEFAQYIBQEEAQYBDAIGDAsCBgEEAwYBBAMPAiEBCQQNBgkHDwIUAhMDBgQFAQQBBQEGBAUBBgEEAQUBBgULAQgGCwIGAQQBEQMMAQsDDwEUARMBIQERAR4BDgEJARACAQgJAQ0BIQITARQBBgEEAQYDBQUGAQQBBgEFAQYBBQIGBAsBAwELARYFCwEGAQwBIQIIASoCCAMUBA8BEwIhAykBAQQNAQkDIQMTAQ8CIQgGAQQBBgEEAgYBBAIGAwsFFgErBQsDCAEsAggDDwETAhQFDwEUAiEBKQEhASkDIQUTAQsBDg8LAgwDBwQKAQIBJQEHBQgCIQEIAQcBCAEsAg0DDwQUBg8FFAEhARQBEwEUAggBKgEhAQgGBwgIAwcDLQgHAQgBLgIIAQcBCgIaAg0CDwEUAQ8BFAsTARQBDwEUARMECAESAQgFBwIIAgcCCAEHAggSBwEvAQoBIAEQASACGwEgAQ0CDwENAQ8CFAITAQ8CEwEUAw8BEwEUAwgBBwEIASEBLAMHAS0EBwQIBwcBLQsHAQsBBwIAAxABCgEeAiABDQsPAg4BCAsHAS0DMAEWAQMBBwItBQcBJQMHAi0MBwEtBBAPCgEICgcBMQEABRYBKwEyAS0BBwEvAyUDLQEHAi0QBwIKAxACAAgKAjMBBwElCAcBNAEKAgABAgEZATMBHwItASUBNQIlARYELQQHAS0EBwEtBQcBLQIHAi0DBwMKAQAHCgEXCQcDLQEHAS0BBwItAgcBLQI1ATIBMAEWATABFgEwATYBMAotAwcCLQoHARcBGAIXAR4BGAIKARgBNwEHAS0EBwQtAQcILQEyAQoJFgYtBAcCLQgHAi0BBwItAwcBGwE4ATkCFwE4BwcBLQQHBi0BJQE6AQoBAwkWAzIEJQEtAgcBLQwHAS0GBwEgATMBOwEtAQgGBwctAjUBMgElATQBAQMDCBYBMgEvAyUBLQElDy0CBwMtAQcBLQQHDS0FJQE2AgECAwECAwMBFgIDASYFJQEvASUBLQEHAyUPLQIHDS0DJQEyBCUBMgE2ATwBHgQJAQEBAAEOARYBPQE0ATYBLwE2BDUEJRctBCUCNQMlATICNgE1BDICNgE6AScBKAQVAT4BIAEoAj8BNAEyAjUEJQItBCUCLQElATUBJQEtAiUBNQglATUCLQIlATICNQEyAS8CNgEvATIBNgIyAjQBOgE0AzYDPwE0AkABNgJBATIBNQYlATUFJQIyAS0BJQEtBSUBLQUlATUBJQMtAS8BMgI2AS8BNQE2BDIBLwEnAS8BNAEnAToBNAE6AScBNAEvATYBLwE0BTYBMgEvAzIBLwE2BjUTJQcyATUBNAE1ATIBFgE2AS8BNgEvATIBQQFAASgBNAEWASgBJwE6AScBOgE/ATYCNAM2ATUBNAE2ATUFJQIyEiUBMgI1ASUBMgE1ATIBFQEbATUBAAEWATACFgE2ATQBNgI6AScBAwEWAScBAgEWAScBPwI0AjYCNAI2AzICJQUyAzUDMgQ2AS8BQQE6ATIBNQI2AzIFNgEzAgMBFgEDARYBAwIWATQCOgE0ARkGFgEnAT8BFgE0AjYFNAFAAjYBLwEyBDYDNAI/AzQBLwI/AjQGNgEvAjYBJwE/ASoBAwIWAgMEFgEoAScBCgsWBjQBPwE2Ai8DMgE2ATIHLwIyAi8CNgEyBTYBNAM2AjQBAgERAg8BDgEPAhMBDgEZAS8BJwECAxYBAwgWBDoBKAEnAToHJwE0Az8ENAE2AjQGNgE0AT8BNgI6AicBNAEnAR8DCgEBAgkBHwEoAicBAgEJAQIBAwMWAgMHFgEVBD8BOgM/AzQCPwQ0AjYBNAI/AjQBOgEnAT8DOgE/ATQBPwM0Aj8BJwE/AUIBIAM6AScBKAEKAQMBCQEDARYCAwkWAjoBKAE6ASgBOgEnAToBPwEoBjQBNgQ0AScFNAQWARkBFgM6AScDNAQ/ARwBKAEcAScBCgEBAQMCFgEDBhYBAwEWARIBEwEOBDoBPwEnAT8CJwI0AjoBJwY6BCcBOgEBAgMEFgEVAToBKAEnBDoFPwE6AgoBCQECAQMBFgEDARYBEwEDAhYBAwITAhQBFwEnAToCPwE0BCcFOgInAT8ENAE/ATQCPwEVAgEDAgEDBjoCJwE/ASgCFQEoARUBHwEeAQkBDQEPARQBAwEWBQ8BIQETAQ8BEQFCASgBJwE6AigBOgQoAjoJKAEnBSgBOgEoASABKAM6AScDOgExASABHwEWBDoBGgIBAg0BDwEUAREBFAQNAQ4BEQEVASgBOgEnCDoDKAE6ASgHOgInASgBOgInAToBJwE6AicCOgInASgBFQMWATsBAwEwAyABFQIKAg0CDwEhAh8BHgIbAR8BFQEoAjoBJwM6ARUBOgIVAToBFQE6Aj8EKAFCAygBQgYoAT8BPgEoAjoBJwEbASABAQYWAQABIAEVARsCIAEVATgCGwEOBRUCKAFCARUCQgMoAToBFQgoBDoEKAE6AUICOgEVAigDOgIoARUBHgERAQ4DEwEWAQIBGwEcAygCFQMgARkBHAEnASgBFQgoA0ICKAE6AUICHAFCASgBFQM6AUIBKAI6ASgDOgFCAToBFQIoAScCKAEnAhUBGAEPAQ4CEQIBARUCJwI6ASgBJwMVASgBOgEoAToEJwI6AT8BJwFCASgCOgFCAjoBJwEVAigBJwYoCzoDKAEVAjoBIAIbAQoCGgEbASAHFQE6ARUBIA8VAToLFQEoCRUBQgEoAhUBKCsVAUIhFQ=="),
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
    unlockRequirement: { none: null }
};