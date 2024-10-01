import { Actor, HttpAgent } from "@dfinity/agent";
import type {
  ActorSubclass,
  HttpAgentOptions,
  ActorConfig,
  Agent,
} from "@dfinity/agent";
import type { Principal } from "@dfinity/principal";
import type { IDL } from "@dfinity/candid";
import { getIdentity } from "../utils/AuthUtil";

export declare interface CreateActorOptions {
  /**
   * @see {@link Agent}
   */
  agent?: Agent;
  /**
   * @see {@link HttpAgentOptions}
   */
  agentOptions?: HttpAgentOptions;
  /**
   * @see {@link ActorConfig}
   */
  actorOptions?: ActorConfig;
}

export const createActor = async <T>(
  canisterId: string | Principal,
  idlFactory: IDL.InterfaceFactory,
): Promise<ActorSubclass<T>> => {
  const host = process.env.DFX_NETWORK === "ic" ? undefined : "http://127.0.0.1:4943";
  const identity = getIdentity();
  const agent = new HttpAgent({ identity: identity, host });

  // Fetch root key for certificate validation during development
  if (process.env.DFX_NETWORK !== "ic") {
    agent.fetchRootKey().catch((err) => {
      console.warn(
        "Unable to fetch root key. Check to ensure that your local replica is running"
      );
      console.error(err);
    });
  }

  // Creates an actor with using the candid interface and the HttpAgent
  return Actor.createActor<T>(idlFactory, {
    agent,
    canisterId
  });
};
