import { readable } from "svelte/store";
import type { Proposal } from "../types/Governance";

let proposals: Proposal[] = [
    {
        id: 1,
        title: "Make Baseball Better",
        status: "adopted",
        description: "Baseball is a great sport, but it could be better. This proposal will make it better. Trust me."
    },
    {
        id: 2,
        title: "Give the community 1,000,000 coins",
        status: "adopted",
        description: "The community is great, and they deserve it. This proposal will give them 1,000,000 coins."
    },
    {
        id: 3,
        title: "Rename the sport to 'Baseball 2'",
        status: "rejected",
        description: "Baseball is a great sport but this one is better so it should be called Baseball 2. This proposal will rename the sport to Baseball 2."
    },
    {
        id: 4,
        title: "Ship it",
        status: "pending",
        description: "Just ship the dang thing already. This proposal will ship it. Just ship it. Ship it. Please ship it."
    }
];
export const proposalStore = readable(proposals);
