import { Principal } from "@dfinity/principal";
import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/team";

export const teamAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);