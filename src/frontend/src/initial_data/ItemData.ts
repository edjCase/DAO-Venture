
import { Item } from "../ic-agent/declarations/main";
import { decodeBase64ToImage } from "../utils/PixelUtil";

export const items: Item[] = [
    {
        id: "power_gauntlets",
        name: "Power Gauntlets",
        description: "A pair of gauntlets that grant the wearer immense strength.",
        tags: ["armor", "enchanted"],
        image: decodeBase64ToImage("WQAAADQbJzIbKDsUJzQbKDUbJzkcHGErK613V4hLKzIbKWAsLIhMKk4qM8CUc9e1lDccKTQcKOjBcL53KycUJ00rMdqFPohMKzQcJzQeJTMaM04sM4hLKt6eQTMbJwAAIDMcJyQSJDQdJ753Kl8tLa13Vl8sLHpIQWAtLTQcJjUcJjMAM00rMjMdJzUdJzUcJzQbJjYdJwAAGjMcKDUcKAAAJCgbKE0rMzIcJzYbKDMaJnpHQjIcKiYWJi4XLsCUdDckJCQkJDQdKWEqKmEsLDEYJFU5OTMeJgAUFDQdKE0zMyYTJiEWLDUeKk0qMmEtLTceJBERETEZKU4rMjMcJTEdJwASEioOKiQWJJcB/wEAD/8BAAEBAQIM/wEDAQQBBQEADP8BBgEHAQgBCQEKAQAJ/wEAAQsBCQEMAQEBAAv/AQ0BDgEPAQkBCwEQCf8BEQEIARIBEwELAQUJ/wEUARUBCAESARYBCQEXARgBGQEABf8BGgEbARwCHQITAQkBHgEfBv8BAAEgAQ4BEgEWAQkBEwEJAQsBGAEhAQAD/wEAASIBDAEJAR0BCAEJARMBIwELAQIBAAT/AR8BJAElARIBDgEJASYBCQETASYBCAEYAQQC/wEAARgCCAETAQ4BJwEmAxMBCQEEBP8BJgEOARIBCAEJAQgBDgMJAQgBJgEiAv8BAAEoAQ4BCAEJASYBCAEWAgkBEwEJASYBKQP/AScBEgITAQgBDgETAQgECQEqAv8BKwEnAQ4BCQEsAQgBFgITBAkBLQP/ASgBEwEJAR0BFgMTAQkBJgEJASYBKQL/ASsBKAEIAQkBJgEdARMCCQETAyYBLQP/AS4BHAEJAxMDCQEYASYBKAEiAv8BAAEvAgkBJgEWARMDCQEmAQkBGAEwA/8BGQEBASUBDgETBQkBJgEBAQAD/wExAQsBCAUJARMBCQEvAQUBAAP/AQABMgENBAkCCAImATME/wEzAQsBCQEOAR0BCQImARwBGAE0ATUG/wE2ATcBHAEJARMBCQImAQkBMwT/ATgBCAEOAQkBJgIJASYBLAECAR8I/wE5ASYBFwEJAggDCQEBAQAB/wE6ATsBCAETAQ4BCQEmAQsBLAEzAQAK/wE8AQsBCQETAQkBCAIJASYBPQE+ARgBPwEIAR0BCQImAQsBMwFAC/8BQQELASMDCQEIAgkBEQFCASwBDwIIAQkCJgELASkM/wEAAUMBCQEOAgkBJgEJARwBRAEYAQ4BEwEJASYBCQEmAQkBAQFFDf8BRgEJAQ4CCQEcAhgBRwFIASkBGAEoAQkBJgIJAUkO/wFKAQsBHAIJARgBHgFLATUBAAFMAU0BGAELAQkBHAFOASIO/wEAAUMBTwEsATcBUAFRBP8BAAFSAVMBIAEYAVQBVRD/AVYBIQE6CP8BVwEhAVgBAMgB/w=="),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "eagle_eye_amulet",
        name: "Eagle Eye Amulet",
        description: "An amulet that enhances the wearer's vision, perfect for spotting enemies from a distance.",
        tags: ["jewelry", "enchanted"],
        image: decodeBase64ToImage("lodLK3pIQXlGQKqAVXpHQSRJJIhKK4hLKjMzM4ZJK655V613V6t2WK14VnFVOXtHQax3V9qFQK53V4hLK3hLPIdNK9+fQBQUJ654WK52WYpMKSoqKq94WIhLLI9QMHtHQnpJQnlHQwAAAK12V3pIQIlKKlVVVXlJQTIbKQAqKg4TIVZxdyQkJBcdKUopMWInJ18tLax3VlhweIGXlqi0sgAkJHtIQK13WIlKK4pKKk4nO4dMLDpIUnpIQnpKQN+eQb52Kldxdq91VXlIQTYbKMjPy1dyd8fPzIGYljtOToCYlDlKT7+VcSRbN1VxeIGXlVh0eam1stqGPSQxPae0szpLUFdwdYCZlHhJPujBb+jBcDNNTYKXl4KXlsbOzOfVs96eQdqGPoCVlai1sjsUJ6m1sb93LOvt6de1lL+VckstNBI3JIKXlXxLPtDakXtJQXdERCQSJMjQzL53K+fUs0BQUIGXl9qFPVVxdgBVVVh0eL+PcNa0lK52V4GYlXpHQFVxdcbQzcfOzMzMzMPMzHlIQICZmXpHPYCYmElJSVVteYWZmai2s8fPzXlJQiAwMDZRUVdyeKi1sXlKQYCAAMfQzQH/AQABAQECGv8BAwEEAf8BBQEGAQcBCBn/AQkBAQL/AQoBCwEMGf8BDQEBAv8BDgEPARABERf/ARIBEwEUBP8BFQELARYU/wEXARgBGQf/ARoBCwEZARsR/wEcAQEBHQEeCP8BHwEQASABIQX/ASIBCgf/AQMBIwEkASUBJgn/ASYBJwIBASgD/wEpASoBKwX/ASwBLQEfAQEBLgEbDP8BLwEwARABMQL/ATIBMwE0A/8BNQE2ATcBOAESATkP/wE6ATsBEAESAQEBPAEzAT0B/wE+ARMBPwETAUABOxT/ATkBEgFBATQBIgH/AUIBQwFEGP8BRQEzAUYBRwFIAUkZ/wFKAUcBSwFMAU0BTgFPGf8BUAFRAScBUgFTAVQBVRj/AVYBVwFYATcBWQFaARYBWwFcASYW/wJdAV4BXwFaAWABYQFiAWMBZBX/AWUBMwFmAV8BZwFaAWgBYAFpAWMBagEmE/8BawFsAW0BEwFfAW4BWgEBAVoBUgFXAW8BcBP/AXEBMwFyAXMDWgFuAVoBYQF0AT0BDxP/AXUBRgF2AQsDWgFfAVoBdwFHAXYBeBP/AXkBegFjAXsBfAFhAloBYQF9AV0BfgF/E/8BeQGAAYEBRwELAXMBGAJgAT4BggF+AYMS/wGEAWMB/wGFAUcBhgGHAQsB/wFiAYgBTwGJF/8BWAGKAYsBjAGNAVwBjhn/AQgB/wFiAY0BjwH/AZAb/wGRAZIBkwH/AZQb/wFiAZUBdq8B/w=="),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "divine_emblem",
        name: "Divine Emblem",
        description: "An emblem imbued with divine magic, perfect for cleansing corrupted energies.",
        tags: ["jewelry", "enchanted", "cleansing"],
        image: decodeBase64ToImage("LiQkJGQsLIpKKoVHKUoqNV8sLGEsLIhMKohLK2AsLF8uLmAtLdqGPolLLIdMLIhKKt6eQYhKLLyUedi1lYlMKodKLL53K4dLKolKLNe0k9W4js7aktDakejBcNDckYlLK4hLKopNLWArK18rK4dLLIdKKohMK4hKK+fVs4dKK9a1lNa0ksOWeIlOJ03/AQABAQECAQMBBAEAGv8BBQEGAQcBCAEJAQoa/wEFAQkCCAEJAQsa/wIIAgwBCAENGv8CCAIMAQgBDhr/AggCDAEIAQ0a/wIIAgwBCAENGv8BDwEIAhABCAERF/8BEgETARQBFQEWAhABFgEXARgBGQEaFP8BGwEcAggBEAIdARACCAEcAR4U/wEfAQgCEAEWAh0BFgIQASABIQ7/ASIBIwEkASUCHwEmAQgCEAEWAhwBFgIQAQgBJwENARQBJQEUAQkBBQj/AgkECAEWARACFgQoAhYBEAEWBAgCCQj/AQgBFgMMAhACHQEcBCgBHAIdAhADDAEWAQgI/wEIARYDDAIQAh0BHAQoARwCHQIQAwwBFgEICP8CCQQIARYBEAIWBCgCFgEQARYECAIJCP8BBQELAxcBEQEOAQgCEAEWAhwBFgIQAggBFwEUASkBEQELAQkO/wEfAQgCEAEWAh0BFgIQAQgBHxT/ASoBHAEgAQgBEAIdARACCAEcASsU/wEsAR4BIQEIARYCEAEWASABDgEeASwX/wEpAQgCDAEIASka/wEOAQgCDAEIAQ0a/wIIAgwBCAEpGv8CCAIMAQgBFxr/AQ8BCAIMAQgBFBr/AQUBCQIIAgka/wEFAQkBCAEHAQYBCRr/AQABAQEtAQMBAQEATf8="),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "artificer_toolbox",
        name: "Artificer Toolbox",
        description: "A toolbox imbued with magical properties, perfect for repairing and creating gadgets.",
        tags: ["accessory", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "dark_essence_vial",
        name: "Dark Essence Vial",
        description: "A vial imbued with the essence of darkness.",
        tags: ["jewelry", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "boots_of_sneaking",
        name: "Boots of Sneaking",
        description: "Enchanted boots that make you move like the wind.",
        tags: ["footwear", "enchanted", "stealth"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "nature_pendant",
        name: "Nature Pendant",
        description: "A pendant imbued with the essence of nature, perfect for cleansing corrupted energies.",
        tags: ["jewelry", "nature", "cleansing"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "boots_of_quickness",
        name: "Boots of Quickness",
        description: "Enchanted footwear that makes you move like the wind.",
        tags: ["footwear", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "treant_bark",
        name: "Treant Bark",
        description: "A piece of bark from an ancient treant, surprisingly sturdy and protective.",
        tags: ["nature", "armor"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "endurance_belt",
        name: "Endurance Belt",
        description: "A belt that magically enhances your stamina. Just don't ask where the energy comes from.",
        tags: ["accessory", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "insight_potion",
        name: "Insight Potion",
        description: "A burst of arcane knowledge that expands your mind... temporarily.",
        tags: ["potion"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "rare_herbs",
        name: "Rare Herbs",
        description: "Exotic plants with potent alchemical properties. Handle with care!",
        tags: ["medicine", "plant"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "nature_crystal",
        name: "Nature Crystal",
        description: "A crystal infused with pure natural energy. It hums with the song of the forest.",
        tags: ["crystal", "nature", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "mysterious_seed",
        name: "Mysterious Seed",
        description: "A seed of unknown origin. Who knows what might sprout from it?",
        tags: ["plant"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "crystal",
        name: "Crystal",
        description: "A simple crystal with latent magical properties.",
        tags: ["crystal", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "faerie_charm",
        name: "Faerie Charm",
        description: "A delicate charm that sparkles with fae magic. It might grant wishes... or mischief.",
        tags: ["jewelry", "fae", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "talking_toadstool",
        name: "Talking Toadstool",
        description: "A sentient fungus with a penchant for dad jokes and bad puns.",
        tags: ["fungus", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "faerie_dance_shoes",
        name: "Faerie Dance Shoes",
        description: "Enchanted shoes that make you dance like a faerie... whether you want to or not.",
        tags: ["footwear", "fae", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "faerie_blade",
        name: "Faerie Blade",
        description: "A elegant, ethereal blade that whispers secrets of the fae realm.",
        tags: ["fae", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "gossamer_mail",
        name: "Gossamer Mail",
        description: "Armor woven from faerie silk, light as a feather but tough as dragon scales.",
        tags: ["armor", "fae"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "enigmatic_bauble",
        name: "Enigmatic Bauble",
        description: "A curious trinket that seems to change its appearance when you're not looking.",
        tags: ["accessory", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "goblin_leader_hat",
        name: "Goblin Leader Hat",
        description: "A crudely made but surprisingly fancy hat. Wearing it might make you feel bossier.",
        tags: ["headwear"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "arcane_tome",
        name: "Arcane Tome",
        description: "An ancient book filled with knowledge of the ages. May cause headaches if read too quickly.",
        tags: ["book"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "battle_manual",
        name: "Battle Manual",
        description: "A comprehensive guide to combat techniques. Now with 50% more diagrams!",
        tags: ["book"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "evasion_scroll",
        name: "Evasion Scroll",
        description: "A magical scroll that teaches the art of dodging. Reading it might make you accidentally dodge your own attacks.",
        tags: ["spell_scroll"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "treasure_map",
        name: "Treasure Map",
        description: "A map leading to buried treasure. X marks the spot... or does it?",
        tags: [],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "egg_of_transformation",
        name: "Egg of Transformation",
        description: "A magical egg that temporarily transforms the user. Side effects may include feathers and a sudden urge to cluck.",
        tags: ["trinket", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "potion_of_unpredictable_might",
        name: "Potion of Unpredictable Might",
        description: "A bubbling concoction that grants incredible strength... with a twist.",
        tags: ["potion"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "essence_of_serendipity",
        name: "Essence of Serendipity",
        description: "A vial of liquid luck. May cause spontaneous four-leaf clover growth.",
        tags: ["potion"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "glow_in_the_dark_potion",
        name: "Glow-in-the-Dark Potion",
        description: "A magical effect that makes your skin glow. Great for reading at night, terrible for stealth.",
        tags: ["potion"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "potion_of_liquid_luck",
        name: "Potion of Liquid Luck",
        description: "A golden potion that promises good fortune. Warning: May cause overconfidence.",
        tags: ["potion"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "fireproof_apron",
        name: "Fireproof Apron",
        description: "An apron that protects against fire. Perfect for dragon-fighting or extreme barbecuing.",
        tags: ["armor"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "harmonic_charm",
        name: "Harmonic Charm",
        description: "A musical charm that resonates with magical energy. May cause spontaneous singing.",
        tags: ["jewelry", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "rhythmic_boots",
        name: "Rhythmic Boots",
        description: "Boots that keep perfect time. Walking becomes dancing, running becomes a musical number.",
        tags: ["footwear", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "novice_whistle",
        name: "Novice Whistle",
        description: "A beginner's musical instrument. May summon woodland creatures... or annoy them.",
        tags: ["trinket"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "laughing_lute",
        name: "Laughing Lute",
        description: "An enchanted lute that finds everything hilarious. Your performances will always have at least one fan.",
        tags: ["enchanted", "instrument"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "bardic_microphone",
        name: "Bardic Microphone",
        description: "A magical microphone that amplifies your voice and charisma. Use responsibly.",
        tags: ["instrument", "enchanted"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "mysterious_artifact",
        name: "Mysterious Artifact",
        description: "An object of unknown origin and purpose. Probably important, definitely mysterious.",
        tags: ["artifact"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    },
    {
        id: "rubber_chicken",
        name: "Rubber Chicken",
        description: "A squeaky toy that's inexplicably part of your inventory. Maybe it's a secret weapon?",
        tags: ["trinket"],
        image: decodeBase64ToImage("BA88Dx9vHy+fLz/PPxf/AgAN/wEAAgEBAAv/AQABAQICAQEBAAn/AQABAQECAgMBAgEBAQAH/wEAAQEBAgQDAQIBAQEABf8BAAEBAQIGAwECAQEBAAP/AQABAQECAwMCAgMDAQIBAQEAAv8BAAEBAQICAwECAgEBAgIDAQIBAQEAAv8BAAEBAQIBAwECAQECAAEBAQIBAwECAQEBAAL/AQABAQICAQEBAAL/AQABAQICAQEBAAP/AQACAQEABP8BAAIBAQAF/wIABv8CADP/"),
        unlockRequirement: [],
        actionIds: []
    }
];