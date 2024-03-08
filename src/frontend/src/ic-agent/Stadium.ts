import { Principal } from "@dfinity/principal";
import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/stadium";
import { get } from "svelte/store";
import { identityStore } from "../stores/IdentityStore";


export const stadiumAgentFactory = (canisterId: Principal) => createActor<_SERVICE>(canisterId, idlFactory, get(identityStore)?.identity);
