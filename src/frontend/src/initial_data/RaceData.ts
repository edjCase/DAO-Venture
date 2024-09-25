import { Race } from "../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../utils/PixelUtil";

export const races: Race[] = [
    {
        id: "human",
        name: "Human",
        description: "Humans are versatile and adaptable.",
        startingSkillActionIds: ["slash", "shield"],
        image: decodeBase64ToImage("AwAAANe1lP///6oB/wsAFP8NABP/DQAS/wUAAwECAAIBAwAR/wEAAgEBAAUBAQACAQEAAQEBABH/AQANAQEAEf8BAAQBAgIDAQICAgEBABD/AgAEAQECAQADAQECAQACAQEAD/8BAA8BAQAP/wEADwEBABD/AQAIAQIABAEBABD/AgANAQEAEf8BAA0BAQAR/wEABgEEAAMBAQAS/wEACwEBABP/AQALAQEAFP8BAAkBAQAW/wEABwEBABf/AQAHAQEAF/8BAAcBAQAU/wMACQEDABD/AQAPAQEADv8BABEBAQAM/wEAEwEBAAr/AQAVAQEACf8BABUBAQAJ/wEAFQEBAAX/"),
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "elf",
        name: "Elf",
        description: "Elves are graceful and attuned to nature.",
        startingSkillActionIds: ["piercing_shot", "entangle"],
        image: decodeBase64ToImage("BOyxHde1lP///wAAAKoB/wsAFP8NABP/DQAS/w8AEf8EAAIBAgABAQEAAgEDABH/BAAJAQIAEf8EAAEBAgIDAQICAQECAA7/AgMB/wQAAQEBAgEDAwEBAgEDAQECAAEDDP8BAwIBAQMDAAoBAgABAQEDDP8BAwIBAgALAQIAAQMO/wEDAQECAAYBAgMDAQIAEP8CAw0BAQMR/wEDDQEBAxH/AQMGAQQDAwEBAxL/AQMLAQEDE/8BAwsBAQMU/wEDCQEBAxb/AQMHAQEDF/8BAwcBAQMX/wEDBwEBAxT/AwMJAQMDEP8BAw8BAQMO/wEDEQEBAwz/AQMTAQEDCv8BAxUBAQMJ/wEDFQEBAwn/AQMVAQEDBf8="),
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "dwarf",
        name: "Dwarf",
        description: "Dwarves are sturdy and resilient.",
        startingSkillActionIds: ["defensive_stance", "double_slash"],
        image: decodeBase64ToImage("BFomGte1lP///wAAAKoB/wsAFP8NABP/DQAS/wUAAQEEAAIBAwAQ/wUABQEBAAIBAwAR/wIAAwECAAMBAgABAQIAEf8CAAMBAgIDAQICAgEBABD/AQMBAAQBAQIBAwMBAQIBAwIBAQAP/wEDDwEBAw//AQMPAQEDEP8BAwcBBAMDAQEDEP8BAw8AEf8PABH/BwAEAwQAEv8NABP/DQAU/wsAFv8JABf/AQMHAAEDF/8BAwEBBQABAQEDFP8DAwkBAwMQ/wEDDwEBAw7/AQMRAQEDDP8BAxMBAQMK/wEDFQEBAwn/AQMVAQEDCf8BAxUBAQMF/w=="),
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "orc",
        name: "Orc",
        description: "Orcs are fierce and resilient.",
        startingSkillActionIds: ["stab", "rapid_shot"],
        image: decodeBase64ToImage("BAAAAGhzP////+3asaoB/wsAFP8BAAsBAQAT/wEACwEBABL/AQAMAQIAEf8BAA0BAQAR/wEADQEBABH/AQAEAQICAwECAgIBAQAP/wMABAEBAgEAAwEBAgEAAgEBAA7/AQAQAQEAD/8BAA8BAQAQ/wEACAECAAQBAQAQ/wIADQEBABH/AQAGAQEDAgEBAwMBAQAR/wEABgEBAwIAAQMDAQEAEv8BAAsBAQAT/wEACwEBABT/AQAJAQEAFv8BAAcBAQAX/wEABwEBABf/AQAHAQEAFP8DAAkBAwAQ/wEADwEBAA7/AQARAQEADP8BABMBAQAK/wEAFQEBAAn/AQAVAQEACf8BABUBAQAF/w=="),
        unlockRequirement: [],
        startingItemIds: []
    },
    {
        id: "faerie",
        name: "Faerie",
        description: "Faeries are mysterious and enchanting.",
        startingSkillActionIds: ["arcane_missiles", "regenerate"],
        image: decodeBase64ToImage("Bkmbnde1lP///wAAALRLY/msuqoB/wsAFP8NABP/DQAS/w8AEf8FAAMBAgABAQQAEf8DAAoBAgAR/wIAAwECAgMBAgIBAQIAEP8BAwEABAEBAgEDAwEBAgEDAgEBAAn/AgQE/wEDDwEBAwb/AgQB/wMEA/8BAw8BAQMF/wMEAf8BBAEFAgQD/wEDCAECAwQBAQME/wIEAQUBBAH/BQQC/wIDDQEBAwP/BQQC/wIEAQUCBAL/AQMNAQEDAv8CBAEFAgQD/wYEAf8BAwYBBAMDAQEDAf8GBAP/BAQBBQIEAf8BAwsBAQMB/wIEAQUEBAT/BwQBAwsBAQMHBAX/BQQBBQIEAQMJAQEDAgQBBQUEBf8JBAEDBwEBAwkEBv8GBAEFAQQBAwcBAQMBBAEFBgQH/wgEAQMHAQEDCAQH/wUEAwMJAQMDBQQI/wMEAQMPAQEDAwQJ/wIEAQMRAQEDAgQJ/wEEAQMTAQEDAQQJ/wEDFQEBAwn/AQMVAQEDCf8BAxUBAQMF/w=="),
        unlockRequirement: [],
        startingItemIds: []
    }
];