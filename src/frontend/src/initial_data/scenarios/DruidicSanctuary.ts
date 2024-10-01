import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "druidic_sanctuary",
    name: "Druidic Sanctuary",
    description: "You enter a serene grove where druids commune with nature. The trees seem to be whispering gossip.",
    location: {
        zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    image: decodeBase64ToImage("VicwJyo4JjREJDdFMTtGOjxKPEZVQ0lXRUtaRlVlTStANSk3LCkzLCg/Kyo5JCMpKi49ITlPJT5VMzlOOCAoICxGLiIyGiEuGB0hICc0FylDKi5IKiAoGTA/ICM2Kys8GxwgGxshGhoeGiE+MyRPOh49LSFkSjSQWDU9QTtCQC9IOiY2Fis6FSg+JCIzEy1IIC0/HC9FFi9AFic8MTNKFzdQGDFJFio4FzBEFzFHFTpXFzBFFDZjGS9aITViRDZ1SSdNMChpLSZhOzN6TCBALyZMLihsNSlvOypEJytQJypdOCY+MihtOitEJTFrOTdTNTNQMSxVLC1YOSlQMi1WNyU9LAMABQECAgcDAwQDBQMGAQcDCAgJAggBBwMGAgUDBAMDAQoCCwEBAgwKAAMBAgIBDQgDAgQCBQQGBAgBCQIIBQkCCAEHAgYCBQMEBQMBCwEBAQ4CAQUAAQ8EAAEBAQ4BEAECAREBAgMDAREEAwMEAQUBBgESBAYFCAEHBQgBCQEIAQYBEgEFAQQBBQETAgMCEQIDAQsBAg8AAg4BEAQCBwMCEwYSBAgBBwQGAggBEwESAgUCBAMDAhICCwQBBwACFAEPBAACDgEQAQ4BEAECARAGAwETAhIBAwUSBQUBBgEFAwYFEwQDAQIECwIBBA4FAAIUBQACDgEBAQABAQEQAgICAwEVAQMBDQYDAxIBEwYFAQQBBQISAQQHAwENAwsCAQEOARAEDgQAAxQCAAQOAQEBAAIBAwIBDAMLAQ0BCwEVAwMBEwMDARMBEgEDAgQBAwQEAQMBCwEKAwMDEQENARABDgEBAg4CAAEOAhABDgEAAhYDFAIWAg4BFAEAAQ4CAQEOARACAgEMAQADDQYDAQoGAwIKAQMBEwIDAQoBDQISAREBCwIBAQIBEAEAAQ4CDwEBAhABDgEQAQ4BFAEWARcCGAIUAhYBGQMUAQ4BAQIOAQACDgEQAQwCCwEaAQsBAQEVAQ0BCwENAwMBFQQDAQoCAwQRAQ0BAwELAQEDAgEOAQABDwEAAQ8CAAEOAhQEFgEUAhgCFAEWAxQBDAEUAQ8BAAIOAQEBDgEBAwABCwEMAQ0CAQILAQ0BGwEVAgsDDQILAg0BAgIRARABDAEBAgABAQEQARYCDgEQAg4BEAEOAQACFAEWARQCFgEYARwCFgIYAhQBAAIOAhACHQIOAQEBAAEPAgABAQEMAQABDAILAgEBDQMCBQsBAQEOAQEDDgEBAQ4BAAMOAR0BDgEdAhABGAEUAhgEFAEcAhcBFgIYARQBDAEUAQABDgEQAQ4BHQECAR0DAAEPAwABDAEPAQwCHgIBBAIBHQEQAQsDAQIQAhEBHQECARABHQECAREBAgEQARQBEAEfAQ4CGAEUARgDFAEWASABIQEUARYCGAEUAxgCFAIAAQEBDgEUAgABFAEAAQ8CAAMPAR4BAAEPAQEEEAEBAQABAQEQAhEBDgICBA4BAAEUAQADFAEWAxgDFAEXAhYBIAEcARQBGAEPARgBDwEYAhQBDwIYAxQBDwIUCQ8BHgEAAg8CAQMeAQ4CEAEOAQABDgIdAQ8CFAkYAQwBHAEUARcBFgEgARwCIAIUASIBGAEPAxQDGAEPARgDDwEUBw8DIwMPASMEHgEUAQ8BFAEPAhQBAQEAAw8HGAEiARgBDwEiARgBDwQYASABHAEWAhgBDAYYCA8BHgEUAg8BHgMjAR4CDwUjAw8BIwIPARgBFAEeAg8CGAEPBxgBDAEYAQ8BGAEiARQCIgEYARQBGAEUAQwGGAUPARgCDwEeAhQBDwQjAxQFIwEUAg8BHgIPARgBFAEeARgBHgIYAQ8BGAEPBRgBCwIPBSIBGAEiARgCDAMYAQ8CGAEPARgBHgEPASMBGAIPASMBGAEUAQ8CIwIkAhQBDwIkASMCJQEUAg8CJAEPAhgBIwEPASUCGAEPARgBDwUYAgwBDwIiARgCIgEYASIBGAIMAQ8CGAEPAhgBHgEYASMBGAEjARgCDwEjAhgBFAIjAiQCFAEPAiYCIwEkAw8BJgEkAQ8CGAEjAQ8BJAIYASMBGAElASICGAEeARgCDAEPBSIBGAEiARgCDAEPARgBIgEjAhgBIwEYASMBGAEmARgCDwEmAxgBJgElAicCFAEPAiYCJQEmAhQBDwImAQ8CGAEkAQ8BJgIYASQBGAEmASIBGAEiASQBGAMMARgEIgEYASIBGAEMASgBDwIiASYCGAEkARgBJgEYASYCGAEPASYDGAEmASUCJwIUAQ8CJwIlAScCGAEPAicDGAEmAQ8BJwIiASYBGAEnASIBGAEiASYBGAEMAQsBAAUiARgBIgEYAQwCKAEYASIBJwEiARgBJgEYAScBGAEnAhgBDwEnAxgBJwEPAicBGAEUAQ8CJwIlAScCGAEPAicDGAEnARgBJwIiAScBGAEnASIBGAEiAScBGAEMAQsBDAEUBCIBGAEiARgBDAIoAiIBJgEiARgBJgEYASYBGAEmAhgBDwEmAxgBJgEYASYBJwMUAiYCJQEmAhgBDwInAxgBJwEYAScBIgEYAScBIgEnASIBGAEiASYBGAELAQoBDAEPBiIBFAEMASkBKAIiASMBIgEYASQBIgEkARgBJAIYAQ8BJAMYASMBGAEjASQBGAIUAiQBJQEeASMDGAImAxgBJgEYASYCGAEkASIBJAMiASMBIgEKAQsBDAEPARgBIgEgASEBIgEYARQBDAIpARgBIgEPASIBGAElASIBHgEYASMCGAIPAxgBDwEYAg8BGAIUBg8BGAEUAR4BDwMYASMBGAEjAiIBDwEiAQ8DIgEYASICCgEMAQ8CIgMhASABFAEMAikDGAEiCBgCDwIYAQ8MFAIYARQBGAEPBhgBIgEhARgBIQEYAyACGAEpAQsCAAIiAyEBGAEUAQwBKQEEBRgBIQYYARQBKgMUASQJFAIPARQBGAEUAQ8BFAEPARgBFAQYAyEBGAUhASgBCgMPARgDHAEYARQBAAEpAQQBFAIPAhQBHAIUARwBFAEXAhYEFwoWBxQBDwQUAhcHHAEXARQBKAEPARgDDwEXARwBFAEPARgCDAEpAQABGAIPARQBHgEXBBYDKwIWASsCHwErAh8BLAQrASoBGgEtBhYBCgMWAS4IFgEUASgCAAEPAQADFAEYARQBDAIPAigCDwEMAhcCFgUrAQECKAEfAS8BMAoxASwBHwEvAjEBMAQfATABLAUrAxYBDgEAARYCGQEWARkCGAIUAQwDDwEpAQQBHwELARkCLAEyAhECMQEfAQ8CMwEeATABNAE1AzYBNAE2ATQBMQI0BDYBMQIwATEBLwIxATIBHwI3ARYBDAEPASgBFAEMARQBAAELAQABGAEPARcDFAEMAR0BAwEOAQABBAEyATgBMAI4ATEBOQE2ATUBNAI2AjUBOgI1AToBNQU6ATUDOgE1ATYDNAM2ATQBNgE7ATEBMAEGATABDAEKAQ8BAAEMARQCDwEMAg8ENwEwATIBMAI4ATsBOQI0BzULPAIqAj0EPAE9AT4BPwE+ASoBIwFAATYENQE0ATYBOAELAQwBHwEPAQABDAIPAgwCNwEdATgCMgI4ATQBOQI0AjUEOgQ8AUEBJAQmASQBJgEjAj8CJAEmASQBJgMkAyYBJwEmATUCOgQ1AjQBOQIyAR8BDgE3AQACDAEfAjICBQE4ATQBNQE0AjUEOgQ8AUECQgMmAScHJgEkAyYBJwYmAiQBPQI8BjoBNQE5ATQBEQEfAywBNwI7BTQBNQQ6AgUCQwJBAkMCJgEnASYBRAEmAiQBRAIlAiYCRAEjAiQBJgInBCYBQwEkAT0EPAM6ATQBNgUyATgBMgE4ATkCNAM1AzoBNQEGAQoBKgEkAUUBQwEnASYCJwFGAkEBPARBAiQCJwEkAUUBJAImASQBQgImAUcCJwEmAScBJgE/ASMBJAIjAR4DOgI1ATgCKAELAQ4BOQE0ATkENQM6AUgBJAFJAT0BJAEnASYBQwInAUcDPAFBAUMBRwMnASYCJwEmAUYDJwFDAiYBJAFCBCcDJgFKASQBKgEtBToBNAEMAQ8BAAEdATkBNAQ1ARIBMAEKAQYCCQEnAUEBJwFDAUcBJwFGAUEEPAEnAUMEJwFBAicCRwMnAUcCJwRBAycBRwJDASMCBwERATUCOgM1BDQFNQEQAQsBKAEpASgBSwFEAUwBQwEmAicBQQM8AUMBJwEmDScBRwEmAkMBQQI8AUEDJwEmAScBCgEpAigBNQI6BDUBNAE7BTUBNAEGAQcCCQEGAU0BSQUnAUYCPAFOAQkBJwFHCCcCRwQnAUMCJwQ8AycBJgJDAR4BBgEoAS8EOgE1ATQBNQE0BTUBAQEoASkBBwEJAU8CPAEnAUMDJwFBAjwBLwElAQkOJwFHAUMBJwEkBDwCJwFHASYCJwFIARUCLwQ6AjUBNAE5AjQBOwE5ASwBDwMMASgBUAE6AVECJwFDAycDPAEqAUsBQwUnAkcBJwFHBicBRQFSAzwBQQMnAUcBJgFDAUgBSQIJARECKAE6AjUBEAEAATgDOQEsARQBAAEUAQ8BFAEKATwBJQInAUcDJwFHAUECPAEkAiUBPgsnASQBRQFTAT0DPAUnAiYBSQEpAQYBKQEKAR4BCwE4AjUBNAE5ATgBNAE2AjQBNQU6ATwBLwEmAScBQwUnAUEBPAI9ASoBIwIqAyMCJAEeASoBPgFFAVQDPAFOAUMEJwJDAScBIwEtAwkBBAERBTUBNAEfASkBBgEHAzUDOgI8AToBVQEmAScBJgYnAUYRPAcnASYBJwEkAR4BTQIoAQoCDAU1ATQBHwEUAQwBKAEGATUCOgEoASkBBwEJAToBLQEeASQDJwFDBicBRwJBCTwBQQFGCScBJAEeAS0BLwUPATICNQEoAQoBDAEZARYBGAEPAQwBNAE1ATkDDAEoAQkBEgEBAR4BJAFDAScBQwsnAT4CJwFGDCcBJgEjAR4BCAEJASkBFQEwASwBMgEvATQBNQEfAQ8CGAEfATgBNAE5ATQCNQEyARQBDwEMAQ8CKAE8ATUBDgElASQDJwEmA0MEJwEmASMCPgEkASYDQwYnASYCIwIAAigBMwEKATAFNQE0ATIBLAE3AR8BOAEyBDQBMgErARkBDwEUAQwBAAE1AToBNQEvASUBRAElASYJJwEjAT4BPwEjCScBQgFEAR4CLwEfAQ8BCgIxAR8DNQE0ATUBNAE5ATgBMgEXATcBAgE5ATsBNAE1BDQBNQE2AzoBDAEHAQgBCQE/AkMCJwE+ASMEJQEUAT4BJgEeASMFJQEkASYBJwFHAT0CNQE6ATgCMgEwATIGNQI0ATkBOAEZAR8BMgE4ATsBOAI0BDUDOgE1ARQBKAEpAQUBBgEJAkMCPgEPAhgDFAIjAg8CFAEWAi0CJQFHAUEBPAU6ATQHNQERATQBOQE4ATIBFgEXARkCMgE5AjQENQM6ATsFDwEMAR4DMwEABRYBAAEeARYCMQI2ATQBNgI1ATwEOgE1AjoENQE0ASkBKAEpASgBCgEMATgBMgEUAhcBNwIyAzsDOQM1ATcCGAQPAxgBFAEyATkBMQI2ATsBMQI2ATQDNQY6ATUDOgE1AToBNQI0ASgBKQEoASkCKAEPARgBGQEsAhcBDAELAigBHwEsATIBOAE5ATQCNgE7ARYBHAEgCBgBMAM2BzUDOgEvAwgFNQI5AjQBKAMpAigBDwEYASABGQErASIBGAIUAQ8BDAQyATgBOQE7ATkBOwEsAS4BKwMuARcBFgEuASwBMgI0ATkENQI6BDUBNAEUAjMBDAEyAjQBHwE4ATQCOQEyARgBFAMPARQBIAEcARcCGQIiASABHAEYAQ8BAAEfAhkDMgE7AjIBLAEyASwBMQI5ATsBOQE2BDQBNgE0AzkBNAE5ATUCNAE5ASACGAEUATICOwI4ATICOAEWBBgBIgEgARwBFwMZAxwBIAEiAhgEGQIsAR8CMgI7ATgBOQE7BDQBOQM0AjkCLAI4AzQBOwEyARwBIQEXARkBHwIyAjcCHwIZARcBIAEiASABIgEcARcEGQEiASABIgEYAhcDGQE3ASsDNwEsAR8BMgEsAjICOwIyARkBLAExAjsCOAEZASEBLgEsATIBLAExATsBLAE3ASwBNwEfATIBLAErAhcCNwIZASwBNwgZARwCIgEPAQABFwEWAhkBKwY3AiwCKwIsATYCMgE3ASwBMgEwASwBMgIsASsBLAE3ATIBLAEfAiwBHwQyBCwCNwEZBDcEGQEXARQBHAMiARgBIAIcARcDGQMrBDcBKwE3ATIBLAEWARcBFgEfBDcBKwQ3AS4BFgIZAR8BMAEsAisBLAE3ATIBLAEyAywENwQZAhcBIQEgBSIBIQEcASECFwEWARcBHAEXARYCGQIXARkCFwEZARYCNwEZATcBHwIZAjcBGQIXAhkCNwEsATcBLAErAiwBNwIZAjABNwQZARcBGQIWAy4BFwYiASABIgEhAiADHAEXAhwBIAEcAhcBFgIXAhYBFwcZARwBGQEWARcCGQEWARkBKwEZAzcBKwMZBBcBHAEgARYBGQIXAhwBIRIiASABIgEYAhwBFgEcBhcBHAIXAhwBFAEXARwCFwEcARcBIQEiAyEBIAIiAiEBIgIhASIBIQIcASEEIg=="),
    paths: [
        {
            id: "start",
            description: "The air is thick with magic and the scent of herbs. What do you do?",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "seek_healing",
                            description: "Seek healing from the druids. Side effects may include turning into a tree.",
                            requirement: [{ gold: 20n }],
                            effects: [{ removeGold: { raw: 20n } }],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                                        description: "The druids' magic flows through you, mending your wounds.",
                                        effects: [{ heal: { raw: 15n } }],
                                        pathId: []
                                    },
                                    {
                                        weight: { value: 0.3, kind: { raw: null } },
                                        description: "The healing magic fizzles, leaving you with a mild case of leaf-itis.",
                                        effects: [],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "commune_with_nature",
                            description: "Commune with nature. Hope you speak fluent squirrel.",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.5, kind: { attributeScaled: { wisdom: null } } },
                                        description: "You successfully commune with nature. A squirrel imparts ancient wisdom, and hands you a nut... er, herb.",
                                        effects: [{ addItem: "herbs" }],
                                        pathId: []
                                    },
                                    {
                                        weight: { value: 0.5, kind: { raw: null } },
                                        description: "Your attempt at communing results in a lengthy conversation with a sassy fern. You're not sure, but you think it just insulted your haircut.",
                                        effects: [],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "leave",
                            description: "Leave the sanctuary. The pollen was getting to you anyway.",
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