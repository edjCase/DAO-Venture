import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/players";

const canisterId = process.env.CANISTER_ID_PLAYERS || "";
// Keep factory due to changing identity
export const playersAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);
