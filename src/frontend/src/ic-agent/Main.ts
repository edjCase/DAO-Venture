import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/main";
const canisterId = process.env.CANISTER_ID_MAIN || "";
export let mainAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);
