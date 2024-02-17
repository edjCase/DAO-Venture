import { Trait } from "../models/Trait";

export let traits: Trait[] = [
    {
        id: "STRATEGIC_ADVANTAGE",
        name: "Strategic Advantage",
        description: "You have a strategic advantage over your opponent and gain a boost to a random skill.",
        effects: [
            {
                skill: {
                    skill: [{ battingAccuracy: null }],
                    delta: BigInt(1)
                }
            }
        ]
    },
    {
        id: "STRATEGIC_DISADVANTAGE",
        name: "Strategic Disadvantage",
        description: "You have a strategic disadvantage playing your opponent and lose value to a random skill.",
        effects: [
            {
                skill: {
                    skill: [{ battingAccuracy: null }],
                    delta: BigInt(1)
                }
            }
        ]
    },
    {
        id: "DEBT",
        name: "Debt",
        description: "You owe a debt and it will haunt you till its paid in full.",
        effects: []
    },
    {
        id: "PRICE_ON_HEAD",
        name: "Price on Head",
        description: "Someone has put a price on your head.",
        effects: []
    },
    {
        id: "STRINGS_ATTACHED",
        name: "Strings Attached",
        description: "Someone did something for you, they may ask you for something in return.",
        effects: []
    },
    {
        id: "MORALE_BOOST",
        name: "Morale Boost",
        description: "You are feeling good about yourself and gain a boost to a random skill.",
        effects: [
            {
                skill: {
                    skill: [],
                    delta: BigInt(1)
                }
            }
        ]
    },
    {
        id: "LOW_MORALE",
        name: "Low Morale",
        description: "You are feeling down and lose value to a random skill.",
        effects: [
            {
                skill: {
                    skill: [],
                    delta: BigInt(-1)
                }
            }
        ]
    },
    {
        id: "BOOSTED_RESOURCES",
        name: "Boosted Resources",
        description: "You have access to more resources and gain a boost to a random skill.",
        effects: [
            {
                skill: {
                    skill: [],
                    delta: BigInt(1)
                }
            }
        ]
    },
    {
        id: "CHEATER",
        name: "Cheater",
        description: "You have been caught cheating.",
        effects: []
    },
    {
        id: "OUT_OF_COMMISSION",
        name: "Out of Commission",
        description: "You are out of commission and cannot play.",
        effects: [
            // TODO?
        ]
    }
];