import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "lost_elfling",
    name: "Lost Elfling",
    description: "You hear the faint cries of a young elf, seemingly lost and separated from their clan. The sobs are punctuated by occasional hiccups that sound suspiciously like 'tree cookies'.",
    location: {
        zoneIds: ["enchanted_forest"],
    },
    category: { "other": null },
    image: decodeBase64ToImage("USMjKyEgIyMsMCMlLSQuNiUuNyY1OCczNiQjKiosLCg/PDQsLypDPipDPSpEQDY0NipGPihAOik5NikeJCIsLjVRSCEsLSs9Piw/P0mAR82jgiIwMCtCPjQ3ODk9OUM7PDs2MkI6N0xDPCwiJXZhTVpZTKV6aJVlVVo1NJZ7aU8+OUw3MzooL0lRRSlAOTExLTJROSkcISw0ODJIOlhsUyxEP0JQSCcxNCkyNSc3NiAzKyU2MlJvQSc3NCcwMi9COSo4NSIvLS48Oyk1ND9FPik2Ni5AOVBaSig0MzdCPitBPS5CPys1N0VLQitDPCk2NCgyMwkAAQELAAEBAQABARYAAQEFAAQBAQABAQUAAQECAAEBAQABAQEAAQEBAAEBAgABAgIAAQMBAgEEAQMBAAEDAQIBAwECAgMBBAICAQQBAgIEAQICBAECAQQCAwECAgQBAgEFAQIBBAECAQMBAgEDAQIBAwEAAQMCAAEBAQABAQEABAEBAAIBAQABAQIAAQEBAwEBAQIBAAUDAQIBAwEEAQUBBAEFAQQBAgMEAQUBBAIGAQcBBAIGAQQBAgIEAQYCBQEEAgUBBAEDAQACAgIDAgIBAwIABAEBAwMAAwEBCAIJAQgBAQEDAQEBAgEEAQMBAQEFAQQCAgEGAQQCBgEFBwYBCgQGAQUDBgEEAgYBBAEGAQUBAQEDAQICAwEAAQMCAAEBAgkBCAIBAQIBAQEAAQMDAQEIAQsBCQELAQEBAwEGAQEBAwEAAQMEBgEFBQYECgEMAQoBDQEKAQ4BCgQGAgQBBQEGAgUBBgEEAQEBBQEBAQQBAgEBAQABAwEBAwgBAQEAAQMBAQEAAQMBAQEDAQEBCAEPAQsBDwEBAQIBBAEAAgMBBQEKAQQBBgEKAgQBBgEEAQYDCgENBRABDQERARIBCgMGAQABBgEFBAYBBQEBAQACBAEIAQMBAgEBAgkBCAEBAQQBAgEBAQABAwEBAQABAQELAg8BCwETAQsBCQEIAQQDBgECAQYBCgEUAgYBAwIKAxAFFQIQAgoCBgEKARYBBgIKARcBBAEYAQoBBgEBAgYBAQEAAQQBAQEJAggBAwIAAQEBAAEDAQEBAwEBAQgBDwELAQ8BCQEBAQMBAQEFAQoBGAECAQYCCgEBAQ4BCgEBAQ4BFQEQAhUBGQMaARkBFQEQAQ4BDAEKARsBBgEAAQoCBgEEAQYBCgEGARcBAQIGAQEBAgEXAggBCQEBAQABAgQAAQEBAAEBAQkBDwELAQ8BAQEHAQQBAAEXAQYBAwEYAw4BAAEVAQoBAQEOARACFQEZAxoBGQEaAxUBDAEQARwBGwEBAQ4BCgEEAQYCCgEYAQ4BAQIOAQEBAAEEAQsBCAEJAQEBAAICAQEBAAEBAgMBAQELAQ8BHQELAQgBGAEKAQEBBgECAQEBFwMOAQMCDgEWAQ4DFQIZBBoBFQEQARUBCgEQARUBCgEBAQYBBAEOAQYEDgEBAgoBAQEEAQkBCwEIAQsBAQIAAQMCAQEAAQYBAAEBBA8BAQIGAQEBBAEPARcCDgEKAQ4BAQIKAQABDgMVBRoBGQIVARABDgEVARABDgEBARcBBgEXAQYEDgEBAQoBBgEBAgABCwEIAQkBEwEAAQUBAwIAAQMBBAEDAQEBDwELAQ8BHgEBARcBBAEAAQsBCAEXARgCDgEGAQEBDgEEAQcEFQEZBRoDFQEKARABDgEMAQEDDgEEAQ4CFQEOAQEBBgEEAQEBBgEXAQEBCwEPAQEBAAEGAQQCAQEIAQABAgEBAQsBDwEfASABCAEYAQsBAQEIAgYDDgEVAQEBCgEUAQYBDgMVARkBFQMaAhUBEAEVAQwCFQEOAQEDDgEXBA4BAQEGARcBAAECAQUBAQILARMBAwEEAQIBAAIBAggBAQELAQ8BIQEfAQ8BCQEBAQgBBAEXAQYCDgEVAQ4BAQEYAQMBCgEVAQ4DFQMZBBUBEAEKAhUBDgEBAQoCDgEGBA4BAQIGAQkBAAIBAQsBDwEJAQABAgEGBAABCwEIAQsCHwEgAQsBAQEXAQEBAwEOAQYBGAEOARUBDgEAARcBAgIOARUCEAYVAhAFDgEBAg4BBgEKAhcBCgEYAQEBFwEEAQgBBQEGAQEBDwELAQ8BAQECAgEBAAEEAQIBCAETAQ8BIAEfAQsBCAEGAQUBCAEFARcBBAEXAgoBDgEAAQ4BBAEKAQ4DFQEQBBUBDgIQARUBCgIOARUBAAEOAQYBFwEGARcBCgIGAQEBBgEFAQgBFwEGAQECCQELAQgBAQEAAQEBAAICAgEBDwEiAR8BDwEBAQUBBgEDAQQBDgEGARcBCgEOAQoBAAEKAQIBBgMOARUBDAIOARUBDgEVAQwBDgQKAQ4BAwEOARcBDgMGARcBBgEBAQQBBQEBAQQBBQEBAgsBIwEBAQIBAQIAAQMCAAEBAQsCHwEhAQEBAgEEAQEBBAEGAQUBFwEYAQoBBgEBAQoBFAEKARUCDgEQBw4CCgEXAQoCFwEBARcBBgEXAQQCFwEGARcBAQEFAQMBAAEFAQABCAELAQ8BEwEIAQMBAAEBAQABAQEDAQABAQELASECHwEBAQUBAwEJAQABFwEEAgYBDgEKAQABDgEAAQYBCgkOAwoBDgEKAhcBJAEEAwYBFwEGAQUBBgEBAQYBCQEIAQQBBQEBAQsBDwEJAQEDAAEBAQMCAAEBAQ8BHwEiASEBAQEEAQIBCQECAQYBAgEGAhcBBgEBAQ4BAwEGARgBDgIKAQYBGgcGARcCBgElASQBBQEEAQYBBAEGAQUCBgEBAQQBCAECAgQBAQEPAR4BCwEBAQMDAAEDAgABAQELASECIgEBAQIBBAEPAQABBAECAQQCBgEKAQMBCgEDAQoBDgEKAQ4BBwEmASACJgUkAiUBJAInAQICBAECAgQBBgEEAQEBBQEBAwIBAQELASABCwEBAQMCAAEBAQACAwEBAQ8BHwEiAR8BCAEEAQMBDwEAAQQBAwEEAQUCBgEBAQYBAwEGARcCBgEmASgBJAInASkBJwEkAicEJAElAgQBAgIEAQMBBAECAQEBAgEBAQIBBAECAQEBCwEfAQsBAQEDAgABAQEDAQABAwEBAQ8CIgEfAQEBAgEDAQsBAQEFAQQBBQEGAQQBBgEBAQQBAAEKAQYBBAEGASoCJwEaASYBJwEaAyYBKQIkASUBIQMEAQIBBAECAQQBAgEBAQUBAQEDAQIBAAEIAQsBHwEPAQEBAwIAAQEDAwEBAQsBHwEiAR8BAQECAQMBDwEBAgUCBAEFAQQBAQEGAQEBBgEEAQYBKQIkARoBJwEaASYBJAEaASYBGgInASUBIgEJAgUBAgIEAQMBAgEEAQEBCQEBAQICAwEBAQsBHwEPAQEBAwEAAQEEAAEBAQ8BHwIiAQgBAwEAAQ8BAQEFAQQBAwEEAgUBAQEFAQABFwIFASQBJQErASQBJgInARoBKAEkASYBJQEkASIBAQEFAwQBAwEEAQMBBAEDAQEBDwEBAgMBAgEBAQsBHwELAQEBAwEBAQABAQMAAQEBDwEfAiIBAQIDAQ8BAQIEAQMDBAEBAQUBAQMFASoBLAMnAhoBJwEaASYCJAErASEBBAEFAQQDAgEEAwMBAQEPAQEBAwEAAQMBAQELAR8BDwEBAQMBAAEBBQABCwEfASUBIgEBAgMBCwEAAQIBAwEAAwIBAQEEAQEDBAETASMDJgEaASgDGgEsASoBKwEkBRoBBAMDAQIBAQEPAQADAwEBAQ8BHwEgAQEBAAEBBAABAwEBAQsDIgEIAQABAwEPAQEFAwEEAQEBBAEBAQUBAgEaASMBLAEnASwBJAIaASQBKAEaAScBKwElASYEGgEDAQIEAwEBAQsBAQIAAQMBAQELASEBDwEBAQMEAAEDAQABAQELAR8BLQEiAQgCAAEPAQEGAwEBAQIBAQEEAgMBJwEoASQBGgEuAhoBLwEaATABGgEoAScDGggDAQEBDwEBAQMCAAEBAQ8BIgEgAQgBAAEDAQEBAAECAQMCAAEPAR8CIgEPAgABDwEBAQMCAAMDAQEBAwEAAQQBAwECAQsCJAEVARkCGgEZATABGQEaASQBJwEmARoCAgMDAgABAwEAAQEBCwEBAwABAQEPAh8BAQEDAwABAwESAQYBAQELASECIgELAgABCwEBAQAFAwEBAQMBAAEEAQMBAgEDASQDGgEmCBoDAwECBgMBAQEPAQEDAAEBAQsBIQEfAQEBAwMAAQMBAAECAQEBCQEfAiIBIAEDAQABDwIAAgMBAgEDAQIBAQIAAQMBAgMDASYHGgEnASMBJQEJAQIBAwICBgMBAAEPAQADAwEBAQ8BIAEfAQEBAwECAgABAgEXAQMBAQELAyIBHwEAAQMBCwEIAQMBAgIDAQQBAwEAAQMBAAEEAQIDBQECASYEGgEmASQBMQEdAQMBAgUEAQUBAgMEAQABCQELAQQBAwECAQgBDwEfASEBAQIDAgABBAICAQEBCwEfAiIBIQECAQABHgEyAQACBQIEAQYBAAEEAQUBAgEFBAYBAgEgARoBJgEnASgBLAEzARUBBQEGAQUDBgEFAQYBBQEGAQQCBQECAR0BAwEGAQQBAwEPASIBIAETAQMBBAEBAQABAwEBAQMBCAEPASEBHwEtASABMgECARcBNAEdAQMCBgIFAQMBBgEyAQUCBgEXAgYBFQE1ASMBJQEnASgBNgMZBQYBFwMGAQUBBgEFAQYBAwE3AQcBBgEIAQsBIgEgASMBAQEDAwABAgIBAQ8BIAIiASEBOAEGATkBDgEHAQYBDgEVARcBBAIGBhcDFQEwASQBJwQZARoBGQEXAQYBFwIGAhcDBgEKAQYBCgEOAQoBBgEIAQsBIQILAQEBAwIAAQIBAQEDAQABCwEgASEBIgEhATgBCgE5AgoCDgEKARcCCgEGAQoBDgIYAQ4BGAEQARUCAQEmASwBAQE6BRkCGAIXAgoBGAIXAQoBDgE5ARICBgEIAQ8BIAELASACAQEIAgABAgIBAQ8BHwEgAR8BIgEJAQYBOQEcAQoBEgIXAwoBGAEcARgEDgEVAQEBOwE6ASYBIAE8ATMBAQQZAg4DGAEcAQoBDgIcAQwBCgE5ARwBFwILASEBIwEPAgkBAQEAAgIBAAEIAQsBIQELASEBIgEdAQcBFwEKAQ4BHAEOARgBEgEKAhwCDgEcAg4BFgIBAT0BOgEnARoCGQE6AQEBOwEBATMBAQIOAQoBDgEKAQ4BHAEOAgoBDgEKARIBBAELAQkBIAEBAQsBDwEIAQEBAAIDAQEBCQIgARMBIAEiAR8BPgEXARIDCgEVARwDDgMQAg4BEQEWAQEBOwE/ASMBMAIZAUABAQE6ATACGQEOATUBDgENARACDQEMAQ0BDgIKAT4BIQEPARMBIAEIAQECCwEIAgABAQEDAQ8BCwEPAQgBCwEfASIBHQEHATkBDgESAQ4BCgIVARABLgEMAQ4CFQEQAkEBAQE6ATMEGQE/ARYBOgEzAhkBNQEOARABDgEQAQ4BEAEuAREBEgE5ATcCDwEJAQgBCwIDAQEBDwELAQABAQEIAQ8BCwETASECCQEhASIBHwFCAQYBOQEYAQoBHAEOAgoEEAIVARYBOgEBATsBLgEZATwCGQEwAToBAQEuATABGQE8BBABDQERAQ0BEQEKAT4BDwILAQgBCQEhAQgBAgEDAQEBAgIAAQMBCwEIAQEBDwEJAQgBDwEhAiIBHgFDAQoBDgEYARAEFQEQARUBEAEIATsCAQETASwBJwEkASUBRAEgASMBAQEOATABPAEZAQ4CEAERAQ0CCgEuAUUBCwEJAQgBAwEIAR8BCQECAQQCAgIAAQIBDwEIAQIBAwEJASEBAAEPAQsBIQEfASIBQgE5AQoBHAENAQwBQgQQAQYBCQE6AQECMQEqASMBJwEqASABLAIxAQ4BRgE8AUcBIgEQAg0BDgEQAQ4BEgE+AUgBRQE+AQIBHwELAQEBGwECAQcBPgEIAQABOAEBAQMBBAECAQgBDwIDASECCQEPASIBSQEKAS4BSgEuARABCgMQAT4BIQELASMBMQETASsBLAEoASwCKwEjATEBOwEjASoBJQEkAQ0BDAEQATUDCgEGARIBBgEHATgBDwELAQgBBwE3ATUBSwEBAgABAwEHATcBBgE3AQMBBwE+AQ8BIgE+AQkBDwEhAg0EEAEuAQwBEAFMASABIwExAQgBQAEjASoBJAEhAU0BIwEwAToBCAETASABKgElAQ4BDAEuAgoCOQEXATkCBwEdAQkBFAEHAQQCLgEbAgABPgEHAQIBBwJCAUUBPgE5AT4BDwEhAT0BAwE+AQoBEgENAi4BNQEuAhABNQIsAQkBQAEjAS4BQQE6ARkBMAEgATwBFgE7ATUBLAElASoBDgEuAREBOQEGARIBCgESATkCBwECAUgBOQE+ATkBEgFIARICAAESAUIBSAESAQoBNQEVARgBOwEcAT4BAwEbAUgBEgFOAS4BEgIQAS4CEAE1ASQBKQEoAQEBPwEzAzABPAEwASoBMAEIARIBNQEmAhoBSgEcARIDCgESATkBNwEbAQcBRQFCARIBNwE+AUgBNQE+AgABEgFIARIBSgEcAUgBNQEVAhIBNQFCAS4BEgE7ARIBPQEuARIBCgEQATUBFQEQASQBKAEkAjsBMAEzBBkBKgEwAjsBNQEaAScBGgEcBAoBEgE5AjcCOQEKAUoBLgFKATkBFQFIAwABSAE+ARQBOQE+AUIBSgEVATUCEgE1ARIBOQE9ATkBLgESATkBHAFKARICEAEqAScBIgFGASwBPAELAxkBIwErATwBKwEBARUBJQEhARoBCgERAgoBEgE5ARIBLgE5AS4BCgESATcBQwEcAUoBRQFDARQCAAEUARUBSgFIARIBBwFIATMBSgEuAT0BEgE9AU4BEgEuAgoBEgEuARABTgQQARUBEgEnAhoBJAEvATEBKAEsATABJQEMAU4BDQElAScCCgISATkBLgE5ARICOQESATkBHAEuARIBFAI+AUsBAwEAAQIBNQEuARUBTgEuARIBLgE1AT0BLgE5ARQBPQEcARICNQEuATUBEQIQAS4DEAE1ASYDGgEVASgCJwEoARwBCgEuAQoBLgUSBC4BSAE5ARsBHAE3ARIBGwFIAQYBSwE3AgABAgEDATkBQgE+ATkBNQEVAUoCEgEuARIBPQESAUsBQAEuAU4BEgEuAUMBEgENBBABJgMaATUBJAMnARwBLgIKAREBCgMuATkCEgFKARACFQFCATMBSwFPARQBQgEVATsDAAEHAT4BRgIVARwBPgEQAU4BPQEVAS4BNQIVAS4BSgE5AS4CDQMKAQ0CEAELAScCGgEmATUBJAInASQFEgEKAhIBOQE7AUgBPgE1ARUBQAE+ATUBLgESARQBGAEVATUCAQIAAksBNwFLARUBRgFDARIBNwFLAxUBNQEzAUYBLgE9ATkCEgFKARIBOQEuARIBLgExASUCJwETAUsBKAIkASoBAgI5AS4BOQE7ATcBOwEbATcBSgEVAS4BSAMuAT0BTgIVARIBAAEGAwABAgE1AQIBAwEVAU4BRgIVAUEBNQEVATMBPwIVAU4CEAIuAT0BOwQSASMCLAEjARgBCgEBASoBIgEsAzcDGwECAQMBOQE+ARUBRgFPAjUBFQFPAQABLgESAT4BAAEXAQABQgIAAQEBEgE1AUUBNQEuAUUBNQIVAUMBOwEuARIBMwIVATMBFAFKAS4CEgE9AUgDEgIxAQECCgESAzEGGwIHATsBEgFBARQBLgFIAUoBPQEAAUMBAwEKARcBSwEHAQIDAAEEAQcBCgEuAQIBOQEVAU8CFQE1AT4BFQE1AS4BSAE/ATUBSgESAS4BRgE5AhIBGwEHAUgBAQIxAgYBOwExASMBMQQbAQABBAESAREBLgI7AUABOQEuARIBAwE+AQMBNwE1ARUBBwEDAQcBPgIAAQIBAAFFAUoBSwEBAQoBFQFFATUBFQESAhUBUAFCARIBSAE1ARsBPQE7ARIBGwE7ATcBGwEIAiMBEwEbAQQBAgETATEBEwECARQBGwMSATkBPQFBAS4BOwE+ARYBGwE3AQIBTAEVATUBNwIAAT4BAgEXAQEBAAECARcBAgEAATkBNwEAARIBNQE+ATkBSAFOATMBTgFIAS4BNQESAT4BFAFIARsBPQEbAUEBGwMsAQEBFgEDAQgCLAELAhYBNwFBARsBAgE7ARsBOQE3AQoBGwEBAQMBAAECARUBCgE+AQEBAgIAARcBPgEBAgABBAEHAQEBAAEBARQBAgE5AQoBSwEBATsCLgEUARUBUAEWAQoBNQEuARIBGwE+AQABAwErASABKwMBASMCKwEjAQABFgEDAUgBPQE3ARsBPQEbAjkCAAE+AQABOQEXAQcBNQEGAT4CAgEGAgEBAAIBAQQBAAEXAUsBBgEBARQCAAEEAQEBAgE5AQABBwFCAUUBAgEUATsCPQE7AQMBAQEgASoBKwEBAQABAQEsASoBKwEBAT4BGwISAQABPQEUAT4BOQEbAQABNwEDARcBPgEAAQMCFwE+AQEBAAEGAQICAQMAAQEBAgEDAQIBFwEAAQEBNwE+AQEBAgFCARQBAwEHAQIBCgE9ARIBQQESARsBQQEUAQABAQEsATEDAAErASoBAQESAT0BOQEDBDsBEgECATsBOQECATkBAwEBAQIBBwECAQMBAgEBAQIBAwEBAQABAQEAAQEDAAEBAwABAQwAAQEXAAEBCwACAQEAAQECAA=="),
    paths: [
        {
            id: "start",
            description: "A tiny elf with leaves in their hair and a runny nose looks up at you with big, watery eyes. What do you do?",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "help",
                            description: "Offer assistance to the lost elfling. Hope you're good with kids and have some tree cookies handy.",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.7, kind: { attributeScaled: { charisma: null } } },
                                        description: "Your charming demeanor calms the elfling. You successfully reunite them with their clan, earning eternal gratitude and a sticky hug.",
                                        effects: [],
                                        pathId: ["help_success"]
                                    },
                                    {
                                        weight: { value: 0.3, kind: { raw: null } },
                                        description: "Your attempt to help turns into an impromptu game of hide-and-seek. Unfortunately, the elfling is winning.",
                                        effects: [{ damage: { raw: 2n } }],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "investigate",
                            description: "Carefully investigate the area before approaching. Time to put on your detective hat and look for tiny footprints.",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.6, kind: { attributeScaled: { wisdom: null } } },
                                        description: "Your careful investigation reveals a trail of breadcrumbs... er, acorns. You safely guide the elfling back to their clan.",
                                        effects: [],
                                        pathId: ["help_success"]
                                    },
                                    {
                                        weight: { value: 0.4, kind: { raw: null } },
                                        description: "While investigating, you accidentally disturb a nest of angry pixies. They're small, but their pinches hurt!",
                                        effects: [{ damage: { raw: 1n } }],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "use_perception",
                            description: "Use your keen perception to locate the elfling's clan. Time to channel your inner bloodhound!",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.8, kind: { attributeScaled: { dexterity: null } } },
                                        description: "Your sharp senses lead you straight to the elfling's clan. They're impressed by your tracking skills and pointy ear envy.",
                                        effects: [],
                                        pathId: ["help_success"]
                                    },
                                    {
                                        weight: { value: 0.2, kind: { raw: null } },
                                        description: "Your keen perception leads you right into a patch of giggling mushrooms. Their spores make you see double... of everything.",
                                        effects: [{ damage: { raw: 1n } }],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "abandon",
                            description: "Continue on your way, leaving the elfling to its fate. You're an adventurer, not a babysitter, right?",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 1, kind: { raw: null } },
                                        description: "You walk away, trying to ignore the sniffles behind you. Suddenly, you feel a tug at your heartstrings... or is that just indigestion?",
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
            id: "help_success",
            description: "The elfling's clan showers you with gratitude and rewards. You're now an honorary elf, pointy ears pending.",
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