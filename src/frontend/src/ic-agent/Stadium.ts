import { Principal } from "@dfinity/principal";
import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/stadium";

export const stadiumAgentFactory = (canisterId: Principal) => createActor<_SERVICE>(canisterId, idlFactory);
