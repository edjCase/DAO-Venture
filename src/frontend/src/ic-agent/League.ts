import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/league";
import { get } from "svelte/store";
import { userStore } from "../stores/UserStore";

const canisterId = process.env.CANISTER_ID_LEAGUE || "";
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory, get(userStore)?.identity);
