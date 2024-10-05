import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData =
{
    id: "trapped_druid",
    name: "Trapped Druid",
    description: "You stumble upon a druid entangled in a pulsating magical snare. The vines seem to be... singing? This is either a very strange trap or the world's worst botanical boy band.",
    location: {
        zoneIds: ["enchanted_forest", "ancient_ruins", "scorching_desert"],
    },
    category: { "encounter": null },
    image: decodeBase64ToImage("YyYuNikkKCYxRy8yOTc2OTIpKik0PS46RCY2TC5BVi0+Ty05SjA1QS4+TTQ8RTgvKyRCYyUcICtEaylFZCFDVyJFcji01ytEVSZFbD88Pz41MydZij5GUzIuLyhvsStegjnA6S1dgidLhSpGeT44OCVHdB8ZHS5YciRejSZhkiZSbyhQZ0VBQCJKfi8kIy1SbidoiS9FWVA6MytrmyVMXTw2OSUbGyhRbC9UZzopJTdLXCIaGjUrKzBcezIiHDhIVy1uk0szKFQ3KEUtI1ZZWUk+NB8ZHFJFQDhWaTckIDI/WD7X+Tc+US9VbStCbTpSYDVUWzlRXzCDrjA4SyIYHCqBojdAUjFxiUKWqDBIWTNugyxxmju02jdoeT5YaD1lbTdFVTZdei1FhwsAAQEzAAEBBwABAhcAAQIIAAEBBQABAwMAAQQBBQ8AAQYCAAEHAQABCAUAAQgBAAEJAQoBCAcAAQsBCAECBQABAgoAAQsBAAEMAQsBBgIAAQsBBwENAQ4BDwEEBAABBgIAAQYBAQEAAQEBCQgAAQEBCAECAgACAgEQAwIBCAICBQABAgMAAQYBAAICAggDAAMCAQYBCwEHAQMBBgUAAQICCwEAAQIDAAEBAQABAgMAARECAAESAQEBBwEAAQIBEwESARQBCAEVAQgBFgEUARcBEwEAAQgCAgIAAQgCAgEIAhQBGAQQAQICBgECAQABGQEDARoBAgEJAgABGwESAhwBBAEIAgIBAAECAQgCAAERARkBAQERAR0BCAEAAQYCAgEGARQBCAEYAh4BGwEUAR8BIAEhAQIBFAECAQYBBwQAAQgCFAMQAQgBIgEjARQBBgEKAQABJAEdAQEBAAEGAQABBgElARQBAgEGAQIBAAEDAggBAAEDAwABAQEmAREBAwIAAQYBAAECARABJQEnAR8BKAIpASUBKgErARABCAEUAQIBAAELBAABBgEIBAICEAICAgABAgEAAQsBLAELAQUBBgELAQkBAgEQAhIBEwEGAQACCAQAAQIBBgIRAgIBAQECAQgBEAIIARABJQEpARABLQEpAR8BFAIAAQIGAAEGBQABFAEbAQgBGAEtASkBCQEQAQgBCgENAQQBLgEHAQsBAQEnAS8BCQITAQIBAQEkAwIBAwEEAQEBEQEdAQYBAQEDAQgBGwEOAQABFAEnASIBCAEpASoBCAEwASgBKQEhASMBBgUAAQYEAAEJAS0BGwEYARsBCAECASUBIQIUAQgBAgEIAQUBAgEAARIBMQEJAQIBJQEKAQEBAgELAQYCAAEEAQABAQEmAS4BCAESATIBJQEYAR4BCQETAhABEwEpAjMBFAEbAR8BFAEQBQABBQIdBAABAgEqASkBIwEvARMBKQEhAS8BEgEIAQYBCAEaAgABEwEJAQoBEgEJAQUCAAEGBAADAQERAQgBCQEcASUCLQEbAQEBFAEzAQEBCAEvATQBFwIQASIBFAECAQYCAwIdAQUDHQEDAQsCCQEpARABHgEhARACEwEIATEBFwElATUBEQIvAQoBCwEAAQEBBgEvASEBCgEGAgABAQERAQEBNgEuARMBLwEyAhMBEAEpASEBAQEYAQABNwErAQEBKQEbASEBLQElAQkBAwYdAg8BHQEDAS0BIwEYASEBKQEhAS8BCQEIAS4BEwErATgBLwE5Ai8BEgEMAS4BLwETAQIBEwE6AQcCGgE7AREBPAEuAQcBCQE9ASQBGwE9AQgBJQEUARMBPgEuAT8BIQEvARABLwICAhABCQEDAQ8EHQIPAR0BAwEQARcBGAFAARQBOAEfATABEwFBARMBGAElARMBQgENATEBCQFDAToBJwE4ARMBAgEUAQABJAEBATYCLgECAQgBCQFEAQoBCAEGAQABAgEAAS8BQwEJAS0BEAEIARMBLwICAQgBAAECAQMFHQEPAh0BAwEAAQMBCAEYASUBAwEvAUABBQEkARABGwEiARIBRQEOAQkBNQEcATEBCAETASEBAgEIAQEBAwEmAi4BAQEGAgIBRAEJARABAgEGAgIBCgE5ARMBLQEqARgBKQETAQgBAgMGAQwCAwEdAgYCHQIDAQoBCwEYASkBFAEDARMBEAEAAQoBEAEtASMBEwFBARkBDwEdAycBAgEUASIBAgERAUYBOwE5AT4BAgEJAUQBRwFIAhABCwEIAQIBLgEEAUUBKQEVARsBMwElARIBAgEAAwYBAwEAAS4BAwEGAQICAwEdAQMBBgEQAQIBFwEhAToBHAFDATECEgETAQABCgFBAUkBBQEhARsBGAESAQkBBgEUAQEBSgI7Aj4BRQFHAToBCAEtARgBJQELAgIBEQEaAQgBLQFLASkBLQEzARwBCQMGAgMCHQEDAggBAwE8AQABAgEYASIBBgEAATEBHQE3AUMBPQEIAS0BGAEUAQEBQQFJAS4BIQEtARABIQE4AQABRQJCAzsBNgEDAQoBEwEtAUsBGwEQAQsBAgEuAT4BDAEUAhsBLQEzATcBCgEMAQMCDwEGAR0BPAEDAQYBMwEJAQMBHQEuAQABAgEbAQgBKQEMARoBTAFBASMBEwESAQgBEAEHAjkBSQEqARQBSwEQAQgBDgFBAhECOwFJAT4BAgEHAQgBFAEVARABCAE8AUkBPgE5AQ0BEAEpARgBAAEQAQgCBgEDARoBHQECAjwBBQELATMBSgEDAR0BPAECAQMBCAIbARABAwEZAUMBPAEQAQgBAAEKAQgCSQEuAhUBTQE6ATIBQQEPAggCOwE5AREBAgEGAgECLgJDAUEBEQEFAQgBEAEIARABBgEDAQwDBgIDAQYBBQE8AQMBCwEiARMBAwEdAg8BPAEDAQYBCAIEAQABBQFBAQoBCQEGAhQBAQE5AT4BEQEIASwBBAIBAwIBOwFGAhEBAgERAS4BOQJJATkBEQEuAggBGQEAAQYBRwEEAQMBBwEIAgYCAwEMAQ8BPAEMAQoBKQETAQQCHQEPATwBAwEIAR0BDwEEAQwCRwFBARoBHQEHARgBCAEuATkBEQEuAR0BDwEDAUoBFAEIAQYCEQE7ARECNgI+AUkBEQEFAggCFAEOAQABCwJEAUcBCgEUAQYBAwEAAQMBDAEPAQwBCgEJAS0BJQEMAR0CDwIdAQkBPAEPAQsBCgEJARkBDwJCATkBEAEJAQIBAAE+ATYCPgEIAQkDCAI7AUYBNgFGATYCEQECAwgBEAEUARABRAECAQcCDAEGAQoBGAELAwMBBAEdAQsBCgEXASgBGAEMAQQBBQEPAh0BCwI8AQkBCAEMAR0BCQELAQ8BQQFJAS4BEQE7AkkBPgE2AQIBFAIIAQsCOwFGATYBRgERAgIBCAEUAQgBRAFHAkQBMgEIAQIBAwEGAQwBCAEQAQoCAwEMAQQBAwEKAhABKAFOAQcBBAIPAR0BAwELAg8CEAEMAQMBCQIIARoBOQFBAUkBPgE2AjkBNgERAQgCAAEGAzsBLgERATsBOQNBAUcBQgEGAS0BCgEPAgMBDAIDARQBIgEIAQwBAwIMAQcBFAIQASkBGAEJAQQBHQEPAR0BDAEHATwFRAEKAggBEAEDAR0BEQE8AQ8CSQE+ATYBAQNPAzsBLgERAS4BOQEuAQUBGgEkAQgBEAElAQoBBQE8AQYBDAEDAQwBCgElAQgBAgEDAQwBBwEJARMBKgEtASkBJQETAQoBBAEPAR0BAwEHAg8BAgEIAhABDAFQATgCUQIcAREBNgEuAjkBEQEuARECAAI7AzYBOQERAQICCAECAQkBFQElAQoCBQEHAQwBAwEMAQoBGAEJAQwBAwILATEBKgEoASkBUgEtATEBCQFTAQ8BHQEMAQoCDwEIAQoCEAEdAQoBFAECAgACBwELAREBLgE+AzYBEQEAAjsBVAE2AQ8BOQEIAwIBBgEJASUBLQEKAS4BBQECAQwBAwEMAQkBEAEIAQsBUwIJARMBJwEWAksBKQElARQBCwEMAQQBDAEJAQ8BBQEIAQkBEAEJATwBCAETAQYDAAEGAQcBAgEmAjkBNgI7AQECOwFGAREBQwEDARABBgICAQMBCgElAS0BCgE8AQ8CCwIMAQoBGAEKAQIBCwIXASsBKgEzAUsBIAEeASoBEAEJAQ4BBAELAQkCDwIUARABCQEdAQgBEwECAwACBgEHAQgBAQEPATYCOwFGAjsBNgFJATkBAwFOAQMCAgEDARABJQEoAQkBDwEFAQcBCwEMAgcBEAMKAjQBKgEfASkBUgIeAR8BKgEnARcCDQEKAg8BFAEpAS0BCQE8AQsBGAELAQYBAgEUAgYBBwEQAQECPgU7AUYCOQEDAU4BAwECAS0BAwIUASkBCQI8AQsBCgEMAgsCEAEYATQBKgEnATABVQEzAR4BUgEeASkBFgEfAT0BKwETAQkBBAEPAhQBGAEJATUBCwElAQgBAgEKAS8BCQEGAQsBGwEIAkkFOwEuAUkBHQEMARABHQECAQgBBgEIARABMwFWAg8BCwEKAQcBFwE0AVcBWAFVASABVQEwARYBSwIWAVIBSwEWAVIBVQEWAUsBHwEvAVkBGgEUAS0BEAEJAR0BCwEjAQgBLQECARABCAEGAQsBGAEIAREBPgU7AS4BQwFKAQQBEAE8AQIBBgEDARABLQEzAQkCDwEHAQ0BDgE0AVoBUgEWATABWwEgARYBKAEfASgBGwEpAR4BKAEgARYBMwFSAVwBUgE4AT8CNwEUAQkBHQELAScBCAEGAQIBHQEZAU8BCgEtARABAAIuBDsBLgE5ATEBDwEaAQ8BAgEMAR0BFAEtATMBCQE5AR0BCwEOARcBMAFLAVIBVQFLARYBHwIqAR8BKQEoATMDHwFAAUsCKAFcAVUBUAErARgBEAEJAR0BUwEbARQCBgE8ARwBCQEKASUBEAELAkkBNgFGAjsBLgE+ATEBDwEaAQ8CDAEdARQBGwEeAQoBDwEMAQoBFwFdARYBQAFbASABMwIqAT0BMAEgAhYBVQIWASoBNwEwA1IBSwFbATcBGAETAQoBHQFTASIBEAEGAQMBMgFHAQ8BDQEbARABCwFJATkCNgI7AS4BOQFMAggBFAEIAQIBBAIQAR4BCgEPAQcBDQEUAVUBSwFSAVsBHwErASoBQAEfASACFgEgAUsBFgFVATABPQEnATcBHwFAAVIBSwFVASoBEwEKAQ8BUwEtARABBgEDAUMBTAEaAQsBLQEJAQcBEQE5AjYCOwE+ATkBAQIIASABCAEMAQQBEAEYAR4BDQEEAQ0BNAErARYBUgEqAVIBKwEqATMBHwEnATABHgFSAh4BUgFLAlIBIAEpATcCHwFSAUsBKgETAQkBDwFTASMBMQEGAQMBQwIPAQ0BLQEIAQMCOQEuAUUCOwE+AUkBLgEEAUoBLQFOAQ8BGgEVARgBHgEKAQQBFwErAVUBFgEnASoBMwE0ATABUgErAUABUgIgAV4CUgIWASkBHgFLATABKwFSAUABIAEwASsBCQEPAQ4BIwETAgMBQwIPAQoBKQETAQQBQwE+ATYBDwI7AT4BOQEuAQ8BGgIEAQ8BGgIQAR4BCQEEAVkBJwFLAVsBTQE0AR4BFwEoARYBIQFVARYBIAEsAUQBXwEeAVIBIAFAASoBUgEWAU0BNAEoAVwBUgErAQkBDwEOASMBMQEDAR0BBQEPARoBWQFLASMBGgEuATkBNgM7AT4BQwE+AQEDGgEPARoBFwEQAR4BFwELATQBVwEgAVcBTQE0AR4BNAEpAVIBVQFLAVUBIAFcAUcBKQFSAVsBSwFbASoBVQJAATQBKQFbAVIBHwEUARoBDAEeARMBDgEaAQ8BGgEPAQkBFQESAQ8BLgE5ATYCOwFGAT4COQEPATwCGgIPARQBFQEeAgoBNAFcAVIBJwEKATQBHgE0AVIBHwFSAUsCUgEkASkBQwJSAScCWwFVAVwBMAE4ASkBMAFLATABEAEaAQQBGwElAQQEDwEKARUBLwEaAS4BOQE2AzsBSQFBATkBEQEPBBoBFAEVAR4BKwEXASsBIAFSAU8BMQFZAVUBKgFSAScBFgEeAVIBLAFCATYBQgFHAR4BKgEzAVIBVQEfATMBEwEnARYBIAFSATQBGgEEAS0BJQMaAg8BDQEiARMBGgE+ATkBNgQ7AUMBOQERAhoBHQEkARoBEwEbAR4BEwEXAVkBQAEWARcBMQE0ATABXAEWAT0BVQFSARkCQQJHAUEBHgEqATABQAFVATgBMwFKASoBFgFSATABFwEPAQQBLQElAQQCDwIaAQ0BLQETARoBLgFJAT4DOwEuATkBSQIdBCQBEwEbAR4BLQEXAQ0BVwEWASoCNAEnAUsBFgEwAUABIAEaATIBLANBAUcBVQEWAR4BVQFNATMBEwEqAUsBWwEYARABGgEOASIBJQQaASQBDQEtARIBDwEuATkBPgM7AT4BOQE+AQQBHQQEARMBLQEeASUBFwE/AV0BIAFAARcBWQEqAVUBUgFcAVsBIQFHATkBSwEXAUEBPgE5ATMBUgFAAVsBNAEzAS8CUgEgAR8BEwEDAQ4BIwElAQQBGgMdAQoBLQETAQMBLgFDBTsBQwFJAQQBNQEdAQMBDAEOARABJQEeAS0BEwENATQBUgFLAV0BFwEnATABHgIgAUEBSQE7ASgBGgFDATYBQQE+AVwBJwFSATQBHwE3AVIBKgEgAScBEwEEAQ4CJQFMAiwCGQFKAS0BEAEDAQ8BOQU7AjkBGgEEARkBBAEOAQ0BFQEYASkBGwIrATQBQAEgAVgBMAEqASsBNwElAUYBQQE7AUYBPgFDATYBOwFBAUQBRgFRAToBHwEvATABIAEqAUsBPQETAQ4BVgElARgBVgIsASQBGQElAS0BFAEMATkBPgE2AT4DOwFJATkBBQIKAQkBMQEQARgBEAEzARsBKgErASoBMAEWASABFgEfARcBPQFAAREBQgFGAT4BOwE2AUMBOwFBAVQBRgM9ATABXAFSASoBHgEtARMBYAEJASIBGAExAQQBJAEZAQ4BLQEYAQgBGgE+AjkBPgM7ATYBOQEPAgoBCAEQAS0CEAEpASgBGwEYAScBKgEwAVIBSwEWAVUBKgEwAQgBAgEAATYBQQJHAUIBRgEBAREBNAEUASoBMAFLATABSwEbAS0CMQEJARsBJQIQAQQBDAESAS0BEAEMATkBSQE5AUkBPgE7AREBPgFUATkBGgESAhUBJQEVARQCLQIpAx8BMwFVAhYBSwFSATABPQEYAQMBQQFJA0cBJgEIARcBPQEfAUABFgFVATABIAEqARsCEwEbASgBGAEQARQBEwElAhgBDAEaATkBSQERAUMBPgI7ATkBNgFJAg8BFQIQASUBGAEVARsCKQEbAS0BKQEeAVUBIAFVAVIBFgFLAVIBWwEFAUEBMgFDAUIBRwEGA0ABSwEgAVIBMwFSASgBLQIfAhsBLQEVAiICLQEYAQcCOQFJATwCLgE+AjsBPgE5AT4COQE8Ai0BIgIbASIBGwEpAR4CMwEeAVICSwFVAVIBSwFSATABPgFDATICQgFHASoBFgFLASABFgJSATMBUgEpBDMBGwIiASUCGAEMAQ8BOQI+ATYBPAEuAT4DOwE2AUMBSQIuAQ8BGgEOAQkCEwE4AhUBIgEtARsBKQEzAVUBWgFXARYBWAFXAWABRwEuAUcBQgEPAUcBGQFVAVIBSwEgAVIBMwIpARsBJwElASIBLQEYARMBCQFKAVMBHQEPAS4BPgI2AUkBQwEuATYEOwE5AkkBDwFFAUkBBQEPATwBCQEKARgBIgFZASkBLwEnAWEBXQFaAVwBSwEWAVwBXgFZAVIBBwE1AQEBCwIfAhYBSwFSAVcBXwEhASIBGwIcAWABKAFWAUwBNQE8AQ8BBQERAQ8BLgFDAjkBSQE7AQEBOwFGATsBLgFDAUkBRAFHASQBNQEOAQoBEAETASIBHAEhAWABOgMcAV8BUgEWAksBIAEWAUsBIAFLARYBIAVLARYBUgFfAhwBVgEcAUQBTAFKAiIBSgJTAVYBTAEdAQ8DOQE+AQUBAQFGAVQBRgE2AT4BQwFCAUMBBAEdASwBEgENAQoBSgEZASMBLAFEARwBGQEBAkQBXwFaAVgCSwMWAksBIAEWAlIBWAFfAhwBGQEcAR4BTAFHASwBGQEsARoDLAEdAhoBQQFCAUkBPgFUAS4BBQEuAzsBNgEuAUIBQQE5ASQBGgEEAR0CDgEZAUcBRAIEAUQBHAEuAQ8BBQFHBkQBXQJfAkQCMgFHAkQBLgEkARkBGgIZAywBJAFHAhoBRQFEAVcBOQFJATsBAQERAVQBJgIuAUYCOwE5AUMBMgEaAQ8BPAEkARoBEwExAQ4BGgIOAgEBJAI2AUcBQwEuAUQBQQFCATICRwEPAUMBOQFCAUMBLgE5ARECJAFHAQ4DSgFiARkCJAEaATICQgFBATYBPgE2AQUBEQFUAQEBJgFGAREBAQERATYBQgJHAUQCPgI5AhoBDgFgASIBIwE6AxoCNgEFAUEBPgI7AT4BQgERATYBAQEuAUMBGgEDARwBTAEiARMBTgFKASIBSgESAR0COQFBAkIBQwE2AT4BOwEBAhEBJgE7AUYBPAEPAxEBNgE+AjkBQwFCAUEBQgFJAzkCGgIkAToBDgEsATwBMgEFAUUBGQIsATwBRAFgARwBSgFOAWIBKQFMAQ4BDAEkAQ8BLgEZAUUBMgNBAkIBQwE5ATsBVAIBAQ8BGgEFATsCRgE7ATIBLgERAQEBVAEBAVQBOwM2AUUCGgFBAQ8BVgFKASMBCQEjAWIBCQEOARMBEgFOAUwBIwFiAQ4BNQFKAWIBCwEHAU4CDwIaAS4BQQFJAT4CQgU2ATkBLgE8AQEBJgERASYBVAE7A0YBGgMRAgEDEQJGAR0BAQIFAUUCDwEdARoBNQEOARoCGQFKAg8BNQFKASQBGQFFARoBJAMaAQQDDwFJAj4COwEBA0YBHQEDAQUBLgImAUYBJgFGBTsBLgEmAlQBJgFGAREBJgEBAQACAQEAAQEBAAEBAUYBJgIdAQEBJAERAQEBJgEuATkBEQMBAS4BOQVGAQUCHQERAh0BEQEmAVQBHQEAAR0CRgEmA0YIOwFUAjsBJgNGASYBVAERAkYBOwRGAVQBEQJGATsBRgE7BEYBOwNGAVQGRgImBkYBOwJGAVQGRgI7"),
    paths: [
        {
            id: "start",
            description: "The druid looks at you pleadingly, while the magical vines continue their off-key serenade. What's your plan, oh brave adventurer?",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "brute_force",
                            description: "Channel your inner lumberjack and try to muscle through the magical vines. Who needs finesse when you have biceps?",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.6, kind: { attributeScaled: { strength: null } } },
                                        description: "Your impressive display of strength intimidates the vines into submission. They release the druid and slink away, looking thoroughly embarrassed.",
                                        effects: [],
                                        pathId: ["druid_freed"]
                                    },
                                    {
                                        weight: { value: 0.4, kind: { raw: null } },
                                        description: "The vines take offense to your rough handling and decide to give you a tight hug too. Congratulations, you're now part of the world's strangest group hug.",
                                        effects: [{ damage: { raw: 2n } }],
                                        pathId: ["both_trapped"]
                                    }
                                ]
                            }
                        },
                        {
                            id: "nature_whisperer",
                            description: "Attempt to communicate with the vines. Maybe they just need a friend... or a good therapist.",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.7, kind: { attributeScaled: { wisdom: null } } },
                                        description: "Your soothing words calm the vines. They release the druid and curl up for a nap. You've just become a magical plant whisperer!",
                                        effects: [],
                                        pathId: ["druid_freed"]
                                    },
                                    {
                                        weight: { value: 0.3, kind: { raw: null } },
                                        description: "The vines misinterpret your attempt at communication as an audition. You're now the lead singer of 'The Tangled Tendrils'. The druid looks unimpressed.",
                                        effects: [],
                                        pathId: ["singing_contest"]
                                    }
                                ]
                            }
                        },
                        {
                            id: "clever_solution",
                            description: "Look around for a clever solution. Time to put those escape room skills to use!",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.6, kind: { attributeScaled: { dexterity: null } } },
                                        description: "You notice a conveniently placed pair of magical pruning shears. With a few snips, you free the druid. The vines applaud your gardening skills.",
                                        effects: [],
                                        pathId: ["druid_freed"]
                                    },
                                    {
                                        weight: { value: 0.4, kind: { raw: null } },
                                        description: "Your 'clever' solution involves using a nearby beehive as a distraction. Now you have angry bees AND clingy vines. Great job, Einstein.",
                                        effects: [{ damage: { raw: 1n } }],
                                        pathId: ["chaotic_situation"]
                                    }
                                ]
                            }
                        },
                        {
                            id: "leave_alone",
                            description: "Decide this is above your pay grade and walk away. You're an adventurer, not a botanist!",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 1, kind: { raw: null } },
                                        description: "You start to leave, but your conscience nags at you. Or maybe it's the druid's disappointed sighs. Either way, you feel guilty... and slightly less heroic.",
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
            id: "both_trapped",
            description: "Great, now you're both trapped. At least you have company for this impromptu botanical cuddle session.",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "combined_effort",
                            description: "Work together with the druid to escape. Two heads are better than one, especially when they're both wrapped in vines!",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.8, kind: { attributeScaled: { charisma: null } } },
                                        description: "Your teamwork is impressive! You and the druid manage to outsmart the vines, freeing yourselves with minimal embarrassment.",
                                        effects: [],
                                        pathId: ["druid_freed"]
                                    },
                                    {
                                        weight: { value: 0.2, kind: { raw: null } },
                                        description: "Your combined efforts only seem to entangle you further. On the bright side, you've just invented a new form of extreme yoga.",
                                        effects: [{ damage: { raw: 1n } }],
                                        pathId: ["rescued_by_squirrels"]
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        },
        {
            id: "singing_contest",
            description: "The vines challenge you to a singing contest. Winner gets to keep the druid... wait, what?",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "accept_challenge",
                            description: "Accept the challenge. It's time to show these vines who's the real star of this forest!",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.5, kind: { attributeScaled: { charisma: null } } },
                                        description: "Your rendition of 'Leaf Me Alone' brings tears to the vines' nonexistent eyes. They release the druid and offer you a record deal.",
                                        effects: [],
                                        pathId: ["druid_freed"]
                                    },
                                    {
                                        weight: { value: 0.5, kind: { raw: null } },
                                        description: "Your singing is so bad, it actually works! The vines release the druid and flee in terror. Music critics everywhere feel a disturbance in the force.",
                                        effects: [],
                                        pathId: ["druid_freed"]
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        },
        {
            id: "chaotic_situation",
            description: "Congratulations, you've turned a simple rescue into utter chaos. The druid looks both impressed and concerned.",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "embrace_chaos",
                            description: "Embrace the chaos! If you can't beat 'em, join 'em. Time to dance with bees and sing with vines!",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.7, kind: { attributeScaled: { dexterity: null } } },
                                        description: "Your chaotic dance moves confuse the bees and entertain the vines. In the commotion, the druid manages to slip free. You're either a genius or incredibly lucky.",
                                        effects: [],
                                        pathId: ["druid_freed"]
                                    },
                                    {
                                        weight: { value: 0.3, kind: { raw: null } },
                                        description: "Your 'embrace the chaos' strategy backfires spectacularly. Now you're starring in a very weird nature documentary.",
                                        effects: [{ damage: { raw: 2n } }],
                                        pathId: ["rescued_by_squirrels"]
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        },
        {
            id: "rescued_by_squirrels",
            description: "Just when all hope seems lost, a team of highly trained rescue squirrels appears! They quickly free you and the druid, then demand payment in nuts.",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "pay_squirrels",
                            description: "Thank the squirrels and offer them some nuts from your pack. It's a small price to pay for freedom!",
                            requirement: [],
                            effects: [],
                            nextPath: { single: "druid_freed" }
                        },
                        {
                            id: "negotiate_with_squirrels",
                            description: "Try to negotiate with the squirrels. Surely they accept acorns on credit?",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.5, kind: { attributeScaled: { charisma: null } } },
                                        description: "Your smooth talking impresses the squirrels. They agree to a payment plan of one nut per week. You've just entered the exciting world of rodent finance!",
                                        effects: [],
                                        pathId: ["druid_freed"]
                                    },
                                    {
                                        weight: { value: 0.5, kind: { raw: null } },
                                        description: "The squirrels are unimpressed by your negotiation skills. They leave in a huff, but not before pelting you with acorn shells. Talk about tough creditors!",
                                        effects: [{ damage: { raw: 1n } }],
                                        pathId: ["druid_freed"]
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        },
        {
            id: "druid_freed",
            description: "Against all odds (and possibly logic), the druid is finally free! They look at you with a mixture of gratitude and bewilderment.",
            kind: {
                choice: {
                    choices: [
                        {
                            id: "accept_reward",
                            description: "Accept the druid's thanks and any reward they might offer. Saving people from musical vines isn't a cheap business!",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 0.7, kind: { raw: null } },
                                        description: "The druid rewards you with a mysterious seed. They claim it will grow into a mighty artifact, or possibly just a very talkative houseplant.",
                                        effects: [{ addItem: "mysterious_seed" }],
                                        pathId: []
                                    },
                                    {
                                        weight: { value: 0.3, kind: { raw: null } },
                                        description: "The druid thanks you profusely and offers you... a coupon for a free hug from a tree of your choice. It's not much, but it's honest work.",
                                        effects: [],
                                        pathId: []
                                    }
                                ]
                            }
                        },
                        {
                            id: "request_lesson",
                            description: "Ask the druid for a quick lesson in dealing with magical plants. Knowledge is power, after all!",
                            requirement: [],
                            effects: [],
                            nextPath: {
                                multi: [
                                    {
                                        weight: { value: 1, kind: { raw: null } },
                                        description: "The druid gives you a crash course in magical botany. You now know how to properly address a venus flytrap and the best fertilizer for moon flowers. This information will surely come in handy... someday.",
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