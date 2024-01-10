import { Actor, HttpAgent } from "@dfinity/agent";
import type {
  ActorSubclass,
  HttpAgentOptions,
  ActorConfig,
  Agent,
} from "@dfinity/agent";
import type { Principal } from "@dfinity/principal";
import type { IDL } from "@dfinity/candid";
import { get } from "svelte/store";
import { identityStore } from "../stores/IdentityStore";

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



export const createActor = <T>(
  canisterId: string | Principal,
  idlFactory: IDL.InterfaceFactory
): ActorSubclass<T> => {
  const identity = get(identityStore);
  const host = process.env.DFX_NETWORK === "ic" ? undefined : "http://127.0.0.1:4943";
  const agent = new HttpAgent({ identity: identity?.identity, host });

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
