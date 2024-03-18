import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/stadium";


const canisterId = process.env.CANISTER_ID_STADIUM || "";
export const stadiumAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);
