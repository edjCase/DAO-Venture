import { createActor } from "./Actor";
import { _SERVICE, idlFactory } from "./declarations/league";

const canisterId = process.env.CANISTER_ID_LEAGUE || "";
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);
