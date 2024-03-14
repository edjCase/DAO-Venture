import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/teams";
import { get } from "svelte/store";
import { identityStore } from "../stores/IdentityStore";

const canisterId = process.env.CANISTER_ID_TEAMS || "";

export const teamsAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory, get(identityStore)?.identity);