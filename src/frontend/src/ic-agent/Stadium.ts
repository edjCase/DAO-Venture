import { Principal } from "@dfinity/principal";
import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/stadium";
import { get } from "svelte/store";
import { userStore } from "../stores/UserStore";


export const stadiumAgentFactory = (canisterId: Principal) => createActor<_SERVICE>(canisterId, idlFactory, get(userStore)?.identity);
