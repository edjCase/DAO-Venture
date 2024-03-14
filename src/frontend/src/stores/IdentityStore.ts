import { AuthClient } from '@dfinity/auth-client';
import { Principal } from '@dfinity/principal';
import { writable } from 'svelte/store';
import { Identity } from '@dfinity/agent';


type IdentityContext = {
    id: Principal;
    identity: Identity;
};
const authClientOptions = { idleOptions: { disableIdle: true } };

function createIdentityStore() {
    const { subscribe, set } = writable<IdentityContext | undefined>();


    const refresh = async () => {
        let authClient = await AuthClient.create(authClientOptions);
        let identity = authClient.getIdentity();
        let id = identity.getPrincipal();
        if (id.isAnonymous()) {
            set(undefined);
        } else {
            set({
                id: id,
                identity: identity,
            });
        }
    };

    const login = async () => {
        let authClient = await AuthClient.create(authClientOptions);
        await authClient.login({
            maxTimeToLive: BigInt(30) * BigInt(24) * BigInt(3_600_000_000_000), // 30 days
            identityProvider:
                process.env.DFX_NETWORK === "ic"
                    ? `https://identity.ic0.app`
                    : `http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4943`,
            onSuccess: () => {
                refresh();
            },
            onError: (err) => {
                console.error(err);
                refresh();
            }
        });
    };

    const logout = async () => {
        let authClient = await AuthClient.create(authClientOptions);
        try {
            await authClient.logout();
        } finally {
            await refresh();
        }
    };

    refresh();

    return {
        subscribe,
        login,
        logout
    };
}

// Create a store
export const identityStore = createIdentityStore();
