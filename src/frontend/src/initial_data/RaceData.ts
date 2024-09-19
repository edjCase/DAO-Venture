import { Race } from "../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../utils/PixelUtil";

export const races: Race[] = [
    {
        id: "human",
        name: "Human",
        description: "Humans are versatile and adaptable.",
        startingSkillActionIds: ["slash", "shield"],
        image: decodeBase64ToImage("DtS/ldi3lta1lNe1lNe0lNe0kwAAANi1lNm2k9e2lNaylNa0lMOWeNi2lagB/wEADgEBABD/AQIOAwECD/8BBBADAQQM/wEAAQISAwECAQAK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEK/wEBFAMBAQn/AQUGAwIGBgMCBgYDAQUI/wEHBgMCBgYDAgYGAwEHCP8BBxYDAQcI/wEHFgMBBwj/AQgBBBQDAQQBCAn/AQEUAwEBCv8BAQ4DAQYFAwEBCv8BAQwDAgYGAwEBCv8BAwEHCQMDBgYDAQcBAwz/AQkQAwEJDv8BCgUCBgMFAgEKFP8GAxr/BgMU/wELBAMBBwYDAQcEAwELDP8BDAENEgMBDQEMCv8BARQDAQEK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEF/w=="),
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "elf",
        name: "Elf",
        description: "Elves are graceful and attuned to nature.",
        startingSkillActionIds: ["piercing_shot", "entangle"],
        image: decodeBase64ToImage("DtS/ldi3lta1lNe1lNe0lNe0kwAAANi1lNm2k9e2lNaylNa0lMOWeNi2lagB/wEADgEBABD/AQIOAwECD/8BBBADAQQM/wEAAQISAwECAQAK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEK/wEBFAMBAQn/AQUGAwIGBgMCBgYDAQUI/wEHBgMCBgYDAgYGAwEHCP8BBxYDAQcI/wEHFgMBBwj/AQgBBBQDAQQBCAn/AQEUAwEBCv8BAQ4DAQYFAwEBCv8BAQwDAgYGAwEBCv8BAwEHCQMDBgYDAQcBAwz/AQkQAwEJDv8BCgUCBgMFAgEKFP8GAxr/BgMU/wELBAMBBwYDAQcEAwELDP8BDAENEgMBDQEMCv8BARQDAQEK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEF/w=="),
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "dwarf",
        name: "Dwarf",
        description: "Dwarves are sturdy and resilient.",
        startingSkillActionIds: ["defensive_stance", "double_slash"],
        image: decodeBase64ToImage("DtS/ldi3lta1lNe1lNe0lNe0kwAAANi1lNm2k9e2lNaylNa0lMOWeNi2lagB/wEADgEBABD/AQIOAwECD/8BBBADAQQM/wEAAQISAwECAQAK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEK/wEBFAMBAQn/AQUGAwIGBgMCBgYDAQUI/wEHBgMCBgYDAgYGAwEHCP8BBxYDAQcI/wEHFgMBBwj/AQgBBBQDAQQBCAn/AQEUAwEBCv8BAQ4DAQYFAwEBCv8BAQwDAgYGAwEBCv8BAwEHCQMDBgYDAQcBAwz/AQkQAwEJDv8BCgUCBgMFAgEKFP8GAxr/BgMU/wELBAMBBwYDAQcEAwELDP8BDAENEgMBDQEMCv8BARQDAQEK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEF/w=="),
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "halfling",
        name: "Halfling",
        description: "Halflings are small and nimble.",
        startingSkillActionIds: ["stab", "rapid_shot"],
        image: decodeBase64ToImage("DtS/ldi3lta1lNe1lNe0lNe0kwAAANi1lNm2k9e2lNaylNa0lMOWeNi2lagB/wEADgEBABD/AQIOAwECD/8BBBADAQQM/wEAAQISAwECAQAK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEK/wEBFAMBAQn/AQUGAwIGBgMCBgYDAQUI/wEHBgMCBgYDAgYGAwEHCP8BBxYDAQcI/wEHFgMBBwj/AQgBBBQDAQQBCAn/AQEUAwEBCv8BAQ4DAQYFAwEBCv8BAQwDAgYGAwEBCv8BAwEHCQMDBgYDAQcBAwz/AQkQAwEJDv8BCgUCBgMFAgEKFP8GAxr/BgMU/wELBAMBBwYDAQcEAwELDP8BDAENEgMBDQEMCv8BARQDAQEK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEF/w=="),
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "faerie",
        name: "Faerie",
        description: "Faeries are mysterious and enchanting.",
        startingSkillActionIds: ["arcane_missiles", "regenerate"],
        image: decodeBase64ToImage("DtS/ldi3lta1lNe1lNe0lNe0kwAAANi1lNm2k9e2lNaylNa0lMOWeNi2lagB/wEADgEBABD/AQIOAwECD/8BBBADAQQM/wEAAQISAwECAQAK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEK/wEBFAMBAQn/AQUGAwIGBgMCBgYDAQUI/wEHBgMCBgYDAgYGAwEHCP8BBxYDAQcI/wEHFgMBBwj/AQgBBBQDAQQBCAn/AQEUAwEBCv8BAQ4DAQYFAwEBCv8BAQwDAgYGAwEBCv8BAwEHCQMDBgYDAQcBAwz/AQkQAwEJDv8BCgUCBgMFAgEKFP8GAxr/BgMU/wELBAMBBwYDAQcEAwELDP8BDAENEgMBDQEMCv8BARQDAQEK/wEBFAMBAQr/AQEUAwEBCv8BARQDAQEF/w=="),
        unlockRequirement: [],
        startingItemIds: []
    }
];