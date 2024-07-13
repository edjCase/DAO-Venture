import { Identity } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";

let authClientCache: AuthClient | undefined;
let authClientPromise: Promise<AuthClient> | undefined;
const authClientOptions = { idleOptions: { disableIdle: true } };



export const getOrCreateAuthClient = async () => {
    if (!authClientCache) {
        if (!authClientPromise) {
            // Prevent multiple concurrent calls to createAuthClient
            authClientPromise = AuthClient.create(authClientOptions);
        }
        authClientCache = await authClientPromise;
        authClientPromise = undefined;
    }
    return authClientCache;
};

export const getIdentity = async (): Promise<Identity> => {
    let authClient = await getOrCreateAuthClient();
    return authClient.getIdentity();
};