import { ScenarioMetaData } from "../../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../../utils/PixelUtil";

export const scenario: ScenarioMetaData = {
    id: "dark_elf_ambush",
    name: "Dark Elf Ambush",
    description: "A group of dark elves emerges from the shadows, weapons drawn. Their eyes gleam with malicious intent.",
    location: {
        zoneIds: ["enchanted_forest"]
    },
    category: { combat: { elite: null } },
    image: decodeBase64ToImage("MUJjRjlYPkd0SEFsR1SHVFOGVUl4SD1aPC0oLUVrSFWAVEBkPxogHy4zLyw2Lyk9MjFGQC5INTdAOBwdHjI2NBgWGBUOFBQOEWVsajEkKyYXLtvh9jkqJTgtK0IzXD8xKT4nUDgvKTw1LTAyMjw6Mkg9PmNSQDQzNDYyNDk0LkFIRVdSUDw5Mjk1NWRTQFJJSDw5NgEAAQEBAgEDAQQBBQEGAQcBCAEBAQkBCgELAQwBDQUOAQ8EDgEPDQ4BCAEPARABDgMMAQ4BCgECAQEBBgEKAQEBBgEJAQsBBgEDAQsBBgEBAQMBAQEDAQ8BAwEKAQgBCQEOAQMBCgEPAQgBDwERAQIBEgMOAQgBDgIIAQ8CDgEPAhABDwEOAg8CDgEPBA4BEQEPAQ4BCAEPAQwBDgESAQkBAQEOAQkBBgEOAQEBBQERAQ4BAQERAgMBAgEKAQkBDgEBAQQBBwEOAQsBAQEMAQ4BAgEIAQwBEwEMAQ4BDAMPAREBDwEOAQ8CDgEQARECDgIPAQ4BEAEPAg4BDwIOAQ8CEAEPAggBDAETAQwBDgECAREBEwEBAQsBBwEMAREBDgELAQMBBgEHAQ8BCgEGAQ4BAQEIARMBDgEKARQBEwEPARMCCAEOAQwBDgEIAQ8CEAEOAg8BDgIPAQ4BDwEIAQ8GDgIPAQEBCAEOAQ8BAQEPAQwBEwEMAQ4BEgEMAQ4BCAEPAQoBEQEIAQ4BEQEKAREBAwEAAQEBAwEGAQIBFQEUARYBDwEMAQECEwEWAQgBDAEWARMBDwUOAREBDgEPARABDgIIAQ8CDgEPAg4BDwEOAw8BDgEMAQ4BCAEMAQ8BDAETAQgBFQEOAQwBDgEMARABFQEUAQwBCQERAQwBFQEPAQkBDAERAQ4BFwEVARgBFQEXAQ0BDAENAQwBEwEPARMBDQEVAQ8BCAYPARABDwEQAg4BEQMPAg4BDwEOAw8BDgEMAQ8DDgEPAQwBDwEWARMBDAEVAQgBDAITAQ8BEwEVAQwBEwEPARIBFgETARcCDAEQARMBFQEMARQBFQMMARUBEwcPAQgEDgIPAREBEAEOAQ8BDgEPAREBDgEPARABDgEPAQ4DDwEOAQgBDgETARYBDAEWAQ0BEwEOARIBFwEMAQ0BFgEIARcBDAETARUBFgEXARUBFwEMARMBFgEVAQwBFgEMARYBDAETAw4BDAEOAQwBCAIOAQ8CEAEOAQ8CDgEQAQ4EDwMOAg8BEAEOAREBEAMPAhMBGQEVAQgBDAIVARYBEwEXARUDFgEXARMBFQITAhYBFQETARYBEwEWARMBFQEMAQgCDAEOAQwBDgEMAQ4BDwMOAQ8BGgEYAhsBEAEPAg4DDwEMARMBCAETAQwBDgEIAg8CDgEVARMBHAEWARUBDQITARYBDAETAggCEwEXAhUBFgEVARYBEwEdARMBFgEVAQgBFgEIAQwBCAEVAQwCDgEMAQ4BCAMPAR4FGwEQAw8BCAEOAQ8BDAEVAQwBFQIIARUBDAETAgwBFQETARUBHAETAQgCEwEXARUBDAEVAQwBFwEVAQwBEwEVAhMBHAIWARUBEwEWAQgBFQEIAhMEDgEIAw8BGgcbAg8FDgITAQgDEwEVAhMBDAEOARYBFQEZAR8BFgEVARwBFQEZARYBDAETARcCFQETARwBFgEcARMBFwEVARkBFgITAQwCEwMIAg4BDwEOARcBEAgbAg8BFwMPAg4BDAETARUBEwEIARMBFQEMAQ4BCAEOAhYBGQEcARYCHAETARUBEwEMARUBGQITARwBEwEZAhUBGQEVARMBFQITBAgBDgEPAQ4BDwEQASABFwEYBhsBHgEaARcBEgEOAREBCAIPAQ4CFQETAQgDEwEQAQwCDwITARkBFQEZARwBFQIMAQ8BFQUTARkBFQEZARwBFQEOAhMBFQEMAQgBDgEIBA4CEAEaARYBGwEZAxgBIAETARYBEAESAg8BDgEQAQ4BDwEIARYCEwEVARMBDAEQAQwCDgETARYBIQEZAhwBFgMOARMBGQMTARkBEwEZARwBFQEMAQ8BEwEMARMBDgEMAQ4BCAQOARABDwEbARUBCAEYARYBGAEWARsBFwEaARADDwEOAREDDwEVAxMBFQEOARACDgEPARUBEwMZARwBFQEMAQ8BEAEVAhMBGQITAR8BGQEVAQwBFQEOAQwCEwEOAQgBDgEIAQ4BEQIOAQ8BEAEeARgBFgIeARgBHgEaARcBGAETARABDgEPAQ4EDwEVARMBIgITAQ4BDwEIAQ4BDwEVAhMDHAETARUBDgEPARcBEwUcAxMBFgEPARMBCAETAw4BCAIOAg8BGAQbARoBGAEeARgBFwEYARsBCAEVAg8BDgEPAQgBDwEOARUBEwEiARkBEwUOARUBEwEVARkBIQEfARkBFQIOARcBGQQcARMBFQITARUBDwMTAQ4BCAEPAQgCDgMPARIBIwIbARcBHgEYASABFwEeARsBFwEaAQ4BDwEOAQ8BDgEPAQ4BFQETASQBIQEMAQ8DDgEIARUBCAEXARMBHwElARwBEwIOARYCHwEWASEBHAETARcCEwEVAQ8BCAITAg4BDwEIBA4BDAEYAhsBGAEbARUBGgEVAhoBGwEWASABHgEIAw4BDAEIARUBEwEiAR0BDAEOAQ8BDgEPAQ4BFQETARUBHAEfASUBHwEIAQ4BCAEWARwBHwEVARwBJQEZARcCEwEVAQ8CCAETAQ8CDgEPAQ4CDwEMARgCGwEYARsBGAEWARcBGgEXARgBGwETARgBIAEWAg8BDgEIAQwBFQETASECEwEPAQ4BCAEOAQwBFQETAR8BEwEfASUBHwEMAg4BFgEfARwBHwEZASUBHAEXAQwBEwEVAg4BCAETAQ8DDgEPAQ4BDwEeARgDGwEYARsCGAEWAR4BGwEWARoBHgEZARMBDwQOARUBEwEhAQgBEwIIAQ4CCAITARkBHAEmASUBHAEVAQ8BCAEWARwBHwEcASQCHwEXAhMBFQMIARMDDgEPAw4DGAMbAhoBHgEgARsBFgEZARYBGgETAScBDwQOARUDEwEIARMCDgEPAQ4BFQEIARMBHwEmASUBHwETAgwBFQETARwBJQEfASUBHAEXARMBCAEVAQgDEwEPAQ4BCAEPAw4EGwEgARUBHgEYASABFgEbAR4BIAEZARUBFgEXAQ4BCAEOAQgCEwEIAhMBIQEIAQwCDwEOARUBEwEVARwBJgElARwBFQEOAQ8BFQEZAR8DJQETARYBCAITAQ8DEwEOAg8CDgEQARgFFwEWAR4CGAEgARYBKAEeARoBFwEVAggBDgEIAQwBCAUTASkBCAMMARUBEwEVARwBJgElARwBEwIMARcBEwEfAiUBJgETARYCCAEVAQ4DEwEMAQgCDwERAQ8BDgEXARUBGgEVARcBFgEaAiABGgEZARMBIAEaARcBFQEPAg4BDwEOARMBCAETAggEDgETAQwCEwEVARwBJgEfASEBFQIOARYCHAImASUBFwEWAQgBEwEVAgwBCAIMAQ4CCAEPAg4BEwEgAR4CFwIVARYBGgEgARoBIAEaARcBEwEVAQ8CDgIPAgwBDgIPAw4BEwEMAhMBDAEVAR8BJgElARwBEwEPAQgBFQEZAR8CJgElARcBEwEMARMCDAEOAQwBCAEOAQgBDwEIAg4CCAEeASACFwEVARoBIAEeASABHgEgARoBFwETARUBFgMPAQ4BDAEOAQ8CDgEPAQgDDAEIAhMBFQEfASYBJQEhAQwCDgEVARwBHwMlARcBDAITAQ0BEwEMAQ4BDwEIAg4CDwIOARoBIAETAg4BFgEaARkCIAEeASABGgEXARYBGgETARYBDwEOBQ8CDgIMAg4BDAEIAQwBEwEcAiYBHAEVAgwBFgIcAyUBFgEVAgwBEwEIARMDDgEIAQ8CDgEYARsBIAEaAw8BFwIaAyABGQEaARcBFQETARcBEwEIAQ8BDgMPAQ4CDAENAQ4CDAEOAgwBFQEfAiYBEwEVAQ4BDwEXARwBHwIlAR8BFgETARUBEwEMAxMBDAEPAw4BKgETARgCGgIOARcBFQEaBCACGgEXARUBIAETARUBEAEPAQ4BDwIOAQwBCAEpAgwBDwEIAQwCDwEVARwBJQEmARwBFgIMARcCHwIlARwBFQEMAxMBCAEPAQgBDwEOAQ8CDgEYAR4BJwEbARMBFQEXARYBHAEfAhwBFQEbARcBHAEVARcBFgEIARgCCAMOAQ8BCAEpAQ0BDgEPAQ4CDwEIAQwBFQEZAR8BJgEcARYCEwEWARwCHwElAR8BEwEOAggCDAEIAQ8CDgEIAg4BGAEaARgBJwEXAQgCFwEVARwBJQEXAR4BGwEYARMBFwIOARYBHgETAQ4CDwEOAQwCKQEMAg4CDwEMAg8BFQEcASYBJQEZARMCDAEWARkCHwElARwCDAEOAQ8CDAEPAggBDgEPAREBDwEnARsBIAEVAg4BFgEVARcCFQEfARMBGAEgAxUBDwEOAQgBFQIPAQ4BDAQpAQgBDwEOAQwBDwEOAhMBHwEmASUBEwEVAQwBEwEVASEBGQEfASUBHwEWAQ4BCAEMAQgBDgEIAQ8BDgEPAg4BDAEYARsBCAIOARUBFwEcAR8BFwEcARcBFgEYARcBFgEXARUBDgEPASsBIAIOAQwEKQEIAQ8CCAEOBAwBHAEmASUBHAITAQwBLAEZARMBHAEfASYBFQEIAQwBDgEPAQwCCAEPBA4BGgEeARcBDwEOARcBFQEXARUBJgEXAScCCAEnARYBHgEXAQ4BDwEgAhMFKQEIAQ8DDgEPAhMBDgEVAR8CJQEcARUBCAERARwCFQEZASwBJQEZARMCCAEMAQ4BDwEOBA8BDgEgARgBGgEIARMCFwElAR8BHAEXAhgBHgEYARYBGgEXAg8BGgEXARoEKQEIAQ8CDgIPAQgCDgIMARwBHwElAR8BFgEMAQgBHAMTARkBHwEmARMBDAEPAQ4BDAEOAQ8DDgEVARoCGAEgARUCFwEfARUBHAEbARoBHgEbARgBGwEVARoBFQEOARcBEgEjARoEKQIOAg8BDgEMAg4BDAEOARMBHAEfASUBHAEVAQgBFQETAgwBFQEZARwBLAEcARMBDgEPAQ0BDAIOAQ8BDgEIARoBHgEZARYBGwEXARwBFQEgARoBGwEaARUBGAIbARYCGgEOAQgBFwIWAykBDAEOARECDgEMAQ4CDAETAQgBFQEiAR8BJgEfARwBEwIIAg8BDAEhARMBHAEsASYBEwIMBA4CDwEXASABFgENARgBEwEVARkBGAEeARgBFQEIAR4CGwEVARoBIAETBykBCAEOAw8BDgEMAQgBDAEIAQwBFQEcASQBJgEZAR8BHAEVAQwBEwEMAQ4BEwEfARwBEwElAR8BEwEPAQgCDAEIAQ8BFwEqARYBJwEXAS0CFwEeAhgBGgEeARUBGAIbARYCGgEWBykDDwEOAQgBDwIOAQ8BCAETASEBGQIuARUBHAEmARkBEQEMAQ4BEAEOARMBJQEfARMBIQEcAQwBDwEQAg4CDwEIARsBFQEIAxcBIAIYAiABFwEjARgBGwEVARoBGQEXBikBDQIPAQ4CDwEIAg8BDgEMASIBGQEVAS4BJQIVARwBJgIBAQgBEQEQAQgBFQEmAR8BFQEiASEBCAQOAQ8BGwErAw4CFwIgARgBHgIXARYBGAEbARYCGQEXBikBDAEOAQgBDwIIAQ4BDwEIAQwBIQEcARUBEwEmARwBFQETARUBHwEIAQ8BAAEBAhEBDwEVARwBJAETARwBEwEMAQ4BCAEOAhsBEgEPAQ4BFQIXARoDIAMXAhoBFwEgARkCFwYpAQgBDwEOAQ8BEQEPAQgBDgElARwCEwEmAR8BFQEMAQgBDAEcAQgBEQIJAQ4CEQEBAQgBEwIIAw4CDwIbAQgCDwMXARYCGAYXARUBGgEeAxcFKQEMAQ4CEAEPAQ4CEQEfAhMBJgElARkBEwEOAREBDgEBAgkBCAERAQABDgEPARECDwERAQwBDgMPAQ4BGwEUAg4BDAMXARYBGAEgBhcCFQEgARcBIwEXBikBDAEOAQ8BDgIPAQwBCAESASYBHwEZARMBDgEQAQ8CEQEBAREBDwEMAREBAAEBAQ8BDgEQAQEBDgEBAQ4BDwEQAQ8BGwIPAQ4EFwEaAiABGgEVBBcBFQETARUBFwENASQBFwYpAQwBDwIQAhEBAQEOAR8BEwEOAQ8BEAEPAhECDgEIARABEQEMAQgBDwIJAQ4BEAEBAQ4BEAEOAQ8BGwEqAQEBDAEIARcBCAEXARoBFQIaARUCDQIXAhYBFwETARUBJQEsARcHKQEMAQ4DEQEBAREBAAEQAgEBDwEQAhECAQESAQ4BAQERAQ8BDQEOAQkBAAEOAhEBCAIPARgBDgIIARYDCAEeARoBFQETARgBDAINARcBFgEXARMBFgEsASUBJAETASUGKQEIAQ8IAQIJAQEBEAIAAQgBEQEJAQ4BEAEOAREBEAEOARECDgIRAQ4BEQEjAQgBDQEWAggBDAEIARoBIAEYASsBIwMIASkBFwEWARMBFgETCikBEAUAAgEBCQEBAREDCQEBAQkBKgENAgkBCAEBARABDwERAQ4BEQIPAQgBLAEhAQgBKQEWAggBIQIpARcBEwEbASABFQINAikBEwEVARYBFQspAQ8CEQEAAQcBAQEJAQECAwIJARECCQEKAQ8BFAEOARECAAEQAQ4BAAEQAQwBIgElASwBIQIiAQgBJAEIASkBJQIpARcBGgErARMBKQEsBCkBFQEXARULKQEQAQADAQEJAQsBCQEDAgEBAAECAQwBDgEAAgkBAQEPAREBDgEPARECAQEiAiUBIgEhASIBCAgpARUBGAEaBikBFwEVARcKKQEIAQ8BAQIRAQECAAEBAREBDwEBAQICEQIYAQkCAgEKAREDAQERASECJgIlASICIQgpARUBGAETBikBFwEWARMJKQEIASkBCAEOAQ8BCQECAQcBEQEKAREBCQERARABCQEHAw4BEAIJAQABDwEBAREBAQEkAi4BJgMiAi4GKQEhARoBGwEaBikBDQEVARcFKQElAS4BLwEmASQBIQEQAgEBBwIRAQoCAQERAhgBAQEKAgkCAQEQAQ4BEQEPAQEBEQEBASUBJgIfASUCLgEvASIBKQMIAykBGgEYAQgBFwUpARYCFQIpASIBLwEuAiYCLwIBAREBAQEAAREBBwEKAQEBDwEAAQoBAAESAQ4BAQEOAQwBDgEsASIBKQEOAQ8BEQEBARABHAIlAS8BLgIvARwCJgIuASIDKQEXARoBFwYpASEBFwEVAikBJgEuAiYBLgEmARkBEQEDAQABCQEBAQABCgEBAg8BEAESAQ8BDgEJARYBDwEVARMBEgEIATABIgEIAgEBCAElASEBJgEuAS8BJgIvASYELgEsAQgBJQEXASABFQUpASYBLgEXARYBFQElASYCLgEkAS8BHAElAQcBAAELAQEBDwEKAQEBDwEQAhgCCQECAREBAQEXAQEBFgEIATABIQElASIBCAEhASICJAEvAiUBJgEuASUBLwElBS4BIQEaAR4BGgQpASQBJgUuBSYBJQEiAQABBwIBAw8BEQEYAQABAQIPAQEBAAEVARQBDgITATACLAEhAiUBIgEvASUBHAEiASUCLgEmARwBLwUuASUBGgEeASABFwIpASwHLgEmASUEJgEZARECAQERAgECAAESAQ8BDgEPAQEBEQEOASoBEwIIARYBCAEkAQ0BEwEpAywBHAElASECJgEcASEBJQYuARcBIAEeARUCKQElASYGLgEvAiYBLgEmAS4BJgElAQgBDwERAQEBEQEBAQMDAQEPAQABDwEIAQABDwEIAQ4BDAENARMBDwEBAQABCAIlAR8BJAEfAS8BJQEcASUELgImAS4BJgEIAhMBKAETASUDJgQuASYBLwElASYBLwElARwBEQEJAgEBEAERAQABAQEHAREBAQEPAQEBEQEMAQABDgEWAQgBCQESAQwBEgEMARACAQEIBC4CHAElAyYBLgQmAS4BFwETARoBFwImAi8HLgElASYBHwEmASUBAAIBAhECAQERAgEDEQEOAREBDwEVARQBFQEOAQwBKgETARABCAERAQ4CAQEcASYBHAEvBiYBHwImES4BJgEfASYBHAEuAR8BIQIiAR8BJAEPARABEQEAAgIBBwIBARUBEAETAQgBEwIOAQgBDgERAQ4BAQEPAQgBJQEcASYFLgEmARwCJhguASYBLgElASYBCAERAQACAQERAQEBDwEBAQwBEQEIAQ4CEQ=="),
    paths: [
        {
            "id": "start",
            "description": "The dark elves have you surrounded. You must act quickly.",
            "kind": {
                "choice": {
                    "choices": [
                        {
                            "id": "fight",
                            "description": "Stand your ground and engage the dark elves in combat.",
                            "requirement": [],
                            "effects": [],
                            "nextPath": { "single": "combat" }
                        },
                        {
                            "id": "negotiate",
                            "description": "Attempt to parley with the dark elves, offering something in exchange for safe passage.",
                            "requirement": [],
                            "effects": [],
                            "nextPath": {
                                "multi": [
                                    {
                                        "weight": { "value": 0.3, "kind": { "attributeScaled": { "charisma": null } } },
                                        "description": "Your silver tongue convinces the dark elves to let you pass.",
                                        "effects": [],
                                        "pathId": ["negotiate_success"]
                                    },
                                    {
                                        "weight": { "value": 0.7, "kind": { "raw": null } },
                                        "description": "The dark elves are not swayed by your words and attack!",
                                        "effects": [],
                                        "pathId": ["combat"]
                                    }
                                ]
                            }
                        },
                        {
                            "id": "stealth",
                            "description": "Use stealth to sneak past the dark elves without being detected.",
                            "requirement": [{ itemWithTags: ["stealth"] }],
                            "effects": [],
                            "nextPath": {
                                "multi": [
                                    {
                                        "weight": { "value": 0.4, "kind": { "attributeScaled": { "dexterity": null } } },
                                        "description": "You successfully sneak past the dark elves without being detected.",
                                        "effects": [],
                                        "pathId": ["stealth_success"]
                                    },
                                    {
                                        "weight": { "value": 0.6, "kind": { "raw": null } },
                                        "description": "Despite your efforts, the dark elves spot you and attack!",
                                        "effects": [],
                                        "pathId": ["combat"]
                                    }
                                ]
                            }
                        },
                        {
                            "id": "retreat",
                            "description": "Run as fast as you can with the risk of not taking all your gear.",
                            "requirement": [],
                            "effects": [],
                            "nextPath": {
                                "multi": [
                                    {
                                        "weight": { "value": 0.5, "kind": { "raw": null } },
                                        "description": "You manage to escape, but at a cost.",
                                        "effects": [
                                            {
                                                "removeItemWithTags": []
                                            }
                                        ],
                                        "pathId": ["retreat_success"]
                                    },
                                    {
                                        "weight": { "value": 0.5, "kind": { "raw": null } },
                                        "description": "Your retreat fails, and the dark elves catch up to you!",
                                        "effects": [
                                            {
                                                "damage": { "raw": 5n }
                                            }
                                        ],
                                        "pathId": ["combat"]
                                    }
                                ]
                            }
                        }
                    ]
                }
            }
        },
        {
            "id": "combat",
            "description": "The dark elves attack!",
            "kind": {
                "combat": {
                    "creatures": [{ "id": "dark_elf" }, { "id": "dark_elf" }],
                    "nextPath": { "single": "post_combat" }
                }
            }
        },
        {
            "id": "negotiate_success",
            "description": "The dark elves accept your offer and let you pass.",
            "kind": {
                "reward": {
                    "kind": { "random": null },
                    "nextPath": { "none": null }
                }
            }
        },
        {
            "id": "stealth_success",
            "description": "You successfully sneak past the dark elves, finding a hidden cache they were guarding.",
            "kind": {
                "reward": {
                    "kind": { "random": null },
                    "nextPath": { "none": null }
                }
            }
        },
        {
            "id": "retreat_success",
            "description": "You successfully escape the dark elf ambush, but at a cost.",
            "kind": {
                "reward": {
                    "kind": { "random": null },
                    "nextPath": { "none": null }
                }
            }
        },
        {
            "id": "post_combat",
            "description": "With the dark elves defeated, you search their belongings.",
            "kind": {
                "reward": {
                    "kind": { "random": null },
                    "nextPath": { "none": null }
                }
            }
        }
    ],
    unlockRequirement: { none: null }
};