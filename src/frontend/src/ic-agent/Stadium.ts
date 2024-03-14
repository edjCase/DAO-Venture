import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/stadium";
import { get } from "svelte/store";
import { identityStore } from "../stores/IdentityStore";


const canisterId = process.env.CANISTER_ID_STADIUM || "";
export const stadiumAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory, get(identityStore)?.identity);
