import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData =
{
    id: "enchanted_grove",
    name: "Enchanted Grove",
    description: "You enter a serene grove where the trees whisper secrets and the flowers giggle. It's either very magical or you've eaten some questionable mushrooms.",
    location: {
        zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    image: decodeBase64ToImage("ZCYsLysvKSEqKB0nKiEvLR4nKSg3NTM0Li8vJik3Oy08PzhAM0M8JjE5NTIyNEdLMkNAMEY/KEJEMCYzLi83NDY+Mz1AMDQ1MzQ7Kz4+MTlFOSUtKyxISzBBQjI8ODI2LjY5MjI/OzdANRspKy48PTpEMx8vLE9GKzxGODU9NjY/MTNFQSUxLGJmO1VWMDlANjdEPjpCOFFPMEZKNDtOQjVAOqKWR3SbmWZvQE6EiIJ+OT5FN1FQMENaRUpTPHh+RCcwK1thOkJFNldbOTM9OEFLOhokJTxHPjU/OEFMPzpKPT9IPkVMN0BMPD1LOVZjQFBXPEZNNWFqQS83LUtQNURKNn6NRk1VNmNsPSYyLTI6MFlgOkBIM118YD9LNTI9Mx0uKjdFMi87MCAtJwIAAQEBAAECAgMCBAEFAgECAAEGAgcFAAIIAgcCBgMJAgoCCQELBAYBCQEGBQACBAEJAgIBCAEBAQUBAgIFBAABBAEGAQABBAEBAQgBAwEEAwABAgEBAQgBAQEIAgwBCAEGAQABBwQIBAYBCQENAQ4BDQEPARABEQEGAQkBEgELAwYBAQIIAQEBAAEEAQABBgEDAwgDAgEFBAABCQIGAQQBAAIIAQIBBAEAARMBAgEBAQgBDAIHBAACCAEBAQkBBgEUARUBBgEWAQkBFgEXARQBGAIGAQkBDwEGAwkBFwIAAggCAAMJAQECCAMCAQUBAwEGAQkBBgEJAwYCAAEIAQEBBQEEAQIBAQEIAgwBGQEJAQoCAAMIAQYBCQENAgkBCAIJARYBGQEHAQABBgEJARoFCQQbAggBAAMJAQcBCAEMAQgDAgEFAQQCCQEKAQkBHAEAAQQBAAIIAQUBBAECAQgBEQIMAR0BCQEEAgABDAEHAQoCBgEeAQYBHwEHAQkBFwERAgEBBwEgAwYCCQEhAQABCAMJAQABCAEHAQYBCgEcAQABAQEMAggCAgEFAQQBCQEiAQQBBgEjAgQCAAIIAQABAQIMAQkBCgMJAQABAQIMAQABBgEJAR4BJAEMAQYCEQEJAQYBJQEHAQwBEQIGAQkBBgEKAQgBAAQJAQgBDAEJARwBCQEGAQgBDAIIAQEBAgEFAQQBCQEUAgYBBAEmAQQBBgEAAggBAgEIAQwBEQQJAQQBAAEMAREBBgUJAQcBJwEMARUBGgEoAQkBKQEqARkBIAInAREBAQEHARQECQEIAQwBBwMJAQEBDAIIAQEBAgEFASMCBAIAAgkDBAEbAwgBEQESBAkBBAEIAicBBgQJAR4BEQEMBAoBKwIKAh0EJwIRAQwBIAEkAQYBDgERAQgBBAIJAQEBDAEIAQEBCAECAgUBIwEBAQgDBgIEAQYBAAMIAQwBEgIJAQQBAAEsAQgBEQEAAQYECQInAQkDCgEdASsBCgEJAQoDCQIKAQkCEQIMAgcCDAEBAgYBCAEMAwgBAgEFAQMBBAEMAQgBBAMGAgQBAgQIAQQCCQEEAQABCAEMAScBAAEGAwkBGQEnAREBCQEPARACCQEKAgkBHQUJAgoBCQEKAQwBJwERAgwBCAEAAQkBCAERAQwDCAEFAQMBBwIIAQQCCQEEAQYBBAECAggBLQEIAQABCQEAAQYBAAEMAREBDAIJAQoBCQENAS4BBgEJASECCQEKAgkBCgEhAS8BMAUJAR0BCQEKAQkBDgEMAScBEQEIAQABBgEHAREBDAMIAQIBAQEMAggBBAIJAQQBCQEEAQICCAEMARsBAAEJAgABCAERAScBFAMJAQ0CLgEGAgkBMQIJAQoBHQEXAQ0BKwIKAQkBBwYJAR0BFAInAQgBAgEAAQIBDAcIAQwBAgEIBAkBBAECAQgCDAEAAgkCAAEHAScBEQMJASQBJwIuAgoBHQQKASEBIAEJAwoBCQEIAQoDCQEKAgkBBgEnAS4BJwEIAQABAQIMBggBDAECAQgBAAMJAQQBAgEIAS0BDAECAgkBAgEIAQwBJwEHAQoBMgMuAQoBCQIKAQkBIAEJAgoBFwEAAQoBHQEoAR0BCQEMAQADCQEKAQYBCQEzARkCLgEMAQEBCAEMAREBCAEBBQgBAQIIAQkBCgIEAQIBCAIMAQECAAECAQgBEQEuAycCLgQKATQBHQEaAgkBHQEHAQAFCgEMAQcBCQEKAgkBBgEJASQBBgEMAS4BJwEMAQgBDAcIAQIBGwMIAQkBAAEFAQICCAEMAQgBAwECAQgBDAMuAicBCgQJAQoBCQEKAQkBFwIJAQcBJAEKATUBCQIKASQBEQEGAgoBFAEJAgoBCQEUAycBBwIMBQgCAgEJBQgBBQECAwgCAgIIAQwBLgEnAQgBCQIKAgkCCgIJAQYBCgMOARQBCQEdAQoBKwMKAQwBAAIJAQABHQEcAQoBAQIMAS4BJwERAQwBCAEMBAgBAgEEAQoBAAIIAgwBAQECAQgBJwIIAQECCAEMAScBDAIKAR0CCgEJBAoBHgEJAQ4BFgEUARMBCgIcAR0BKwIKAQ4BDAIJAQABCgEdAQYBDAEHAQoBEgEnAREDDAQIAQIBBAEcAgABAgEIAQwBCAECAQgBNgQIARgCDAEJAQoBHAE3AhwECgEJATMBCQEGAQcBDgMJAQoBMAEKAQkBCgEOAQwBBwIAAgkBDAEIAQYBCQEqAS4CJwIMAQgBOAMCAQQBHAEGAQkBBQMIAQEGCAERAScBAQIJARwBOQMcAQoBHQIKAgkBBgEHAQ4BCQIKAR0BNAEJAQoBHQEKAQABDAEIAQABCQEHAQwBBwMJAScCLgIMAwgCAgEEAwkBCgEAAQIBCAECAwgCGAEMAREBJwIJAgoBCQEcAR0DCgIdAQkBDgEAAgcBCQIKASsBJAIcAR0BHAEKAQYDCAIHAQABCQEKAQkBJwEtAToCDAEYAQgDAgEGAgkCHAEJAQUBCAEBAwgDDAIuBAoCHAMKARwBHQEKAQkBBgEAAQcBIAEKARwBCgYcAR0BCQEIAQcBCAEGBQkBOwEtAToBEQIMAQgBAQECAQUBBgEKAgkBCgIJAwICCAE6AgwBOgEnAgoBHQQcAQoFHAEKAQABFwEZAgoBJAEcATcEHAEdARwBBwEMARgBCgEcAR0DHAEdAS0BLgERATYBDAIIAQUBAgEJARwBCQIcAgkBBQIBAggBPAIMAScBDAEdBxwBCgEcAT0BHAEdAQoBCQEOASABLwExAhwBOQYcAQcBDAEHAQoBHAEdAxwBHQE4AS4BJwIMAggCAgEJARwBCQEKARwCCQEFAQICCAE2AgwBJwEyAQkBHQkcAj0CHAEJAQ4BGQEKAxwBNwYcAQcBDAEUAhwBHQEcATcCHAE6AS0BMgIMAQgBGAICAQkBCgIJARwCCQEFAQICCAMMAS4BMgEJAR0FHAE5AxwCPQIcAQYBDgEgAxwCOQYcAQcBDAEJAhwBCgQcAToBLQEuAgwCCAICAQkBCgEJAQYBCgIJAQUBAgIIAhEBLgEtATIBCQYcAjkBHQIcAT0CHAEGAQ4BGQscAQcBDAEKATcFHAE+ATYBOgEuAQwBEQIIAgIBCQEKAQkBBAMJAQUBGwIIAQwBJwE2AToBLgEKAR0LHAEdARwBBgEOARALHAEHAQwBHAE5BRwBPwE2AToBLgEMAScCCAECAQABBgEJAQoBBAMJAgICCAERAScBLgE6AS0BCgEdCxwCHQEGAQ4BEAIcATcHHAEdAQcBGQEJAhwBHQMcAToBNgE6AS0BEQEnAggBAgEAAgYBCQEEAQkBBAEGAgICCAEnATIBLgE2AToCCgIcAR0IHAIdAQYBDgEQAQkBHAE9BxwBCQEHARkBCQYcAjYBOgE2AREBJwIIAgICBgEEAQYCBAEGAQIBAQIIAREBJwEtAToBLQEdAxwBHQgcAgoBBgEOARABCQkcAQkCEAEGAQoFHAE6ATYBOgERAQwBEQMIAUABBAEGAQQBBgEJAgQBAgMIAQwBEQEuAToBLQMdARwBHQMcAh0BHAEdARwBCgEJAQYBFwEZAQkJHAEJAScBGQEUAh0EHAM6AS4BMgERAwgBAQEEAQYBBAImAgQBAgMIAgwBLgE4AS0BCgIdAgoBHAMdAxwCCgEJAQYBFwEgAQkCHQYcAR0BCQEnAQ8BGQEdARwBHQIcASsBOAEtATgBJwEuAScBAgIIAQEBJgIEASYBBAEmAQYBAgEIATYBBwIMAUEBOgE4CB0BHAEdBAoCBgIgAgkBHQEcAR0BHAQdAQYBGQEQARkDHQIcASsCLQEuAREBJwEMAwgBAgQEASMBBAEDAQUCCAEHAQgBGQFBAjoBGQodAQoCCQIGARkBIAIJAQoHHQEGAhkBEAEKAR0CHAEdASsBOAEtAREBDAEnAQwDCAECBQQCIwEFAQgBAQEHAQgBDAMtAQ8JHQIKAgkCBgEgAQ0BLwEJAgoBHAIdAgoBBgEOARkCEAEkBB0BKwE4AS4BEQEMAREBDAMIAQICBAIjAiYBIwEFAQgBAQEMAQgBGQFBAREBLQEuAQoFHQEcAx0BCgQJARkCCQFCBQoBCQEkAQYBDgEgARkBJwEVARQBIQEdAisBOgFBARgDDAEYAggBAgEDAQQBAwEEATcBAAEjAQUBAgEBARgBCAEYATIBEAEuAS0DHQEcAR0BKwQdAwkCJAEvAgkBJAEwAUIBMAIKAiQBBgEXAQ0BFAEnAR4BIAEUASEBKwEwAToBLQEMAScDDAEBAQgCBQQDAgUDAgEYAQgBDAFDAQcBEAEtAUEEHQIrAh0DCQEkAR4BMQEeAiQDHQErAR0BKwIkARQBIAENASkBJwFEAS8BHgEwATQBRQEtAScBDAEnAQcCGAEBAQgBAgFGAgMCAAIFAwIBDAEIAQcBMgEHARkBLgJDAh0EKwEdAiEBRQMwAisBNAErATQEKwFHAUIBMQFIAR4BOwFCATsBSAEaAUkBPgE8AS0BDAEnATIDCAEBAQgBAgEIAQUCAwMFAwIBGAEBAQcBMgEBAQcBDAEHAS4DKwNKASsBNAEwATQBKwQ0Aj0BNAE9AjQBSQE+AUsBSQFKAUkBTAFNAUUBTgFJAj4CLQEHAScBEQEbAQgBGAIIAUYCAgEjARwDBQECAQUBAgEHAQEBCAEnAgEBGQEQAQcBLgFBAS4CNAFKBTQGPQQ0Az0BPgFJAj0CTQJJAT4BRwEuATIBBwEnAREBAAEIAQwDCAFGAQIBIwJGAQUDAgEbAQwBAAEBARkBCAEAAQcBJwEZASABEAE8AkMBTws9ATQIPQFQAz4DUAFRAS0BLgEBARABJwEAAggDAgFGAQIBAwNGAQIBRgECAQEBBwEAAQgBJwEHAgEBGQESARkBUQEZAVABQwE+DD0BTwE9CU8BUgJPAUMBMgFBAREBAQEQAREBAAEBAQgCAgEIAQIBRgEDAQICRgECAUYBGwEHAQEBGwEHAQgBEQEBASABBwEWATwBHwExAUUCPghPAlIBTwdSAjgDUgJBATgBQQEnAS4BBwEBAREBDAECAQgBGAECAQUBCAECAQUBAwJGAQICBQEAAQgCAgEYAQgBDAEZAhYBUwEQAVQBDwEqAVUBQwFSBE8BUgE4AVIFOAY/AVYCOAI/AToBLgEWAScBMgEIAQEBJwEIAQUBCAEYAQEBGwECAQgBRgEFARwBAQEFAgIBGAEIAQIBGwEQAQEBDAEHARgBFgEfAQcBHwISAVQBVwFBAVABTwFSAjgJPwVWAT8BWAFBATIBEQEqARIBEQEMARsBBwEnAgEBCAEYAQEBWQECAQgBAgNGARwBAgEbAQgBAQEfAVoBGAEBAQcBGQEHAhABQgELATMBLgFRAVUBVwEtAlIBOAM/B1YENgE/ATgBWwFUAS4BDwEWARIBEQEIAQEBFgEMBAgBFAE3AQQCAgFGAQUBGwE9AQECAgEfARsBUwEZAQgBAQEZAREBBwEZAQ8BOwFMAQ8BUQFQAkMBWwI4Aj8DVgc2AVYBPwEtAUEBVgFDAVABLgEQAREBCAIBARgDCAIYAT0BNwE5AgUBRgEjAQEBGwEBAjYBHwFTAR8BCAEHAR8BBwE8AQcBHwEPATwBIAEPARYBQwFbAUEBQwE4Az8BVgg2AT8BLQFDAS0BQQJDAVcBFgEMAQgBJQIBARgBBwEYAQEBCAECARsBCQEEAkYBAwEEARsCQAEIAR8BGAEBAR8BVgFaASoBWgEPASUBTwEWAVwCVwFBAVQBLQFSAUEBLQI/A1YFNgI/ATgBWAE4AUMBOAFDAVQBCwESAQwBBwEqATsBUwEYAQwBBwECAQEBAgEAAQIBNAIFASMBNwEcARMBWAFWATYBQgElATsBHwJdASUBKgFMAVYBUAJUAVABLQJXAlIBWAE4AVgCVgY2AT8BWAJBA0MBVAEPAS8BEgFRAR8BWgEqARgCEQEIARsBXQFAATABAAECARsBEwEjAQYBEwEbAgEBGAFWATYBTgEoAV4BCwElAQsBXAElAV4BXAFRAVUBUQI4AU8BWwFYATgBQQE/AVgBVgE6AjYCVgI4AVgBLQFBAlABVwFcASUBGAEPARgCUwIRARgBTgETATkBEwENARQBGwETATQBRgFdARsBJQFYAV8BWgEYASUCKAFOARUBUAFUAVwBTQE3AVECPgFQAk8BTAFXAkEBQwJYAT8DOgFWAToCOANYAUEBWwFDAVcBEgIPAUIBEgIRARYBAQFdAQYBUwEGATcBCQETAQ0BPQJGARMBRgFgASYBVwElASIDKAE2AhYBTAIlAlwBTAE+AVQBTwFdATcBTwFbAVABWwJBCTgBWAFBAVcBQQFDAVQCVwEtARgBEQIYAQgBYQFIARgBFQErAQABQAEsAQQCRgECAlMBRgEsAVkCEwFfAVMEJQELARgBKgFFAVUBUQFXAVwBTARQAVQBTwFbAkEGOAI/AUEBQwFbAkMBPAEPAVcBGAEPARYBEgEYAVwBJQEqASUBEwJZAWIBYwNGAV8BBQEEASYBEwIGARQBWgEoAU8BVAFTAV8BWgI7AVwBPwFMASUBXAFRAUwCUAE+AVEBQwJBAS0COAE/ATgDPwE4AS0CQQFXAVQBVwFUAQ8BVAESAQ8BEgFcAVECWgFiAT0BEwEiAVkBRgEFARMBBQFGARMBBAFZATcBBgMTAlMBFQJTAR8BPgElAWIBCwFhAV4BUQE+AU8BVwFQAVcCLQEuATgCPwNYATgCLQFDAlcCQwFXAlEBVAJcARYBWgEWASoBXAEqAhsBAwEjA0YBIwEmAWABLAEEARsBQwFiARsCEwFbAVYCUwFiARgBEwFIASsBXwJOAU8BUgEWAlQBUAJUAVcCQwI4AVgELQNDAVABUQFMAT4CVAFTARgBQAJaAVMBQAEYATYBAQEjAkYBWQITASMBYgJgAWICYwEEAVkBEwEYAlMBYgFZARMBYgE5ATcBUwFiAVoBUwEYAVoBKgElAT4BVAFXAVACQwFBATgBPwEtAjgCWwFDAVQCUQJMASoBUwEBAVMBWgEYAVMCEwFZA0YBKgFTAkYBYgEFASMBGAIFAWABJgETAQQBAgIsAT4BTAETAVkCEwFZAkABUwFaASkBKgEiAVMBGAFOAVACQwJXA0MBLQFBAUMBVQJXAVQBTAFVATsBAQFTAV8CKgEbASwBAgFGAWMERgJTASYBAwFGASwCUwFaAQUBAgFZARsBYgETAQMBAgEEARQDEwFZAVMBQAFTARgBYgFfARUBWgEqASUBPgFVA1QEQwJQAVECTAEqAVMCWQFTAVkBTgECAkYCEwFjBEYBUgNGAVkBBQJGAQIBAwFGASMBAgEbASMCAwECAgQBJAEEAVkBQAFZBFMBFAFTAV8BKgEaATsBTAJRAVQCUAE+AlACFgFVAQsBUwMbAQIBGwECAQUVRgEDAiMDAgFGAgICQAEsBBMCWQFfARUBKgIYASoBTAJRAlcCFgEYARYBXgFTAQECGwMCB0Y="),
    paths: [
        {
            id: "start",
            description: "The air shimmer with magic, and you swear a squirrel just winked at you. What do you do?",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "meditate",
                            description: "Meditate to increase your magical attunement. Try not to think about acorns.",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.6, kind: { attributeScaled: { wisdom: null } } },
                                        description: "You achieve a state of perfect harmony with the grove. You can hear colors and see sounds.",
                                        effects: [{ heal: { raw: 10n } }],
                                        pathId: []
                                    },
                                    {
                                        weight: { value: 0.4, kind: { raw: null } },
                                        description: "Your meditation is interrupted by a chatty bluejay. You learn a lot about forest gossip, but not much magic.",
                                        effects: [],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "harvest",
                            description: "Harvest rare herbs. The plants look eager... suspiciously eager.",
                            requirement: [],
                            effects: [{ damage: { raw: 2n } }],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                                        description: "You successfully harvest rare herbs, though a fern slaps your hand for picking its cousin.",
                                        effects: [{ addItem: "herbs" }],
                                        pathId: []
                                    },
                                    {
                                        weight: { value: 0.3, kind: { raw: null } },
                                        description: "You grab what you think are herbs. Turns out it's just fancy crabgrass with a good publicist.",
                                        effects: [],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "commune",
                            description: "Commune with nature spirits. Hope you're fluent in squirrel.",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.5, kind: { attributeScaled: { wisdom: null } } },
                                        description: "The spirits grant you mystic knowledge. Unfortunately, it's mostly tree puns.",
                                        effects: [{ addItemWithTags: ["crystal"] }],
                                        pathId: []
                                    },
                                    {
                                        weight: { value: 0.5, kind: { raw: null } },
                                        description: "You have a long conversation with what you thought was a spirit. Turns out it was just a very philosophical mushroom.",
                                        effects: [],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "leave",
                            description: "Leave the grove. The talking trees are getting a bit too judgy about your life choices.",
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