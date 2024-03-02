import { Principal } from "@dfinity/principal";
import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/team";
import { get } from "svelte/store";
import { userStore } from "../stores/UserStore";


export const teamAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory, get(userStore)?.identity);