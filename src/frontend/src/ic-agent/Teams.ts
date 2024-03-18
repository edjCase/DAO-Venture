import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/teams";

const canisterId = process.env.CANISTER_ID_TEAMS || "";

export const teamsAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);