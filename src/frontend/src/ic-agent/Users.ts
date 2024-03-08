import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/users";
import { get } from "svelte/store";
import { identityStore } from "../stores/IdentityStore";


const canisterId = process.env.CANISTER_ID_USERS || "";
// Keep factory due to changing identity
export const usersAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory, get(identityStore)?.identity);
