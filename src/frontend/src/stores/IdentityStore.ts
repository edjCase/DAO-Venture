import { AnonymousIdentity, Identity } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { writable } from "svelte/store";

let authClientCache: AuthClient | undefined;
let authClientPromise: Promise<AuthClient> | undefined;
const authClientOptions = { idleOptions: { disableIdle: true } };


const getOrCreateAuthClient = async () => {
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

export const identityStore = (() => {
    const { subscribe, set } = writable<Identity>(new AnonymousIdentity());


    const login = async () => {
        let authClient = await getOrCreateAuthClient();
        await authClient.login({
            maxTimeToLive: BigInt(30) * BigInt(24) * BigInt(3_600_000_000_000), // 30 days
            identityProvider:
                process.env.DFX_NETWORK === "ic"
                    ? `https://identity.ic0.app`
                    : `http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:` + process.env.LOCAL_NETWORK_PORT,
            onSuccess: () => {
                console.log("Logged in");
                set(authClient.getIdentity());
            },
            onError: (err) => {
                console.error(err);
            }
        });
    };

    const logout = async () => {
        let authClient = await getOrCreateAuthClient();
        set(new AnonymousIdentity());
        await authClient.logout();
    };

    const check = async () => {
        let authClient = await getOrCreateAuthClient();
        set(authClient.getIdentity());
    }

    check();


    return {
        login,
        logout,
        subscribe
    };
})();

export const getIdentity = async (): Promise<Identity> => {
    let authClient = await getOrCreateAuthClient();
    return authClient.getIdentity();
};

