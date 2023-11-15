import type { Identity } from '@dfinity/agent';
import { AuthClient } from '@dfinity/auth-client';
import { writable } from 'svelte/store';


function createIdentityStore() {
    const { subscribe, set } = writable<Identity | undefined>();


    const refresh = async () => {
        let authClient = await AuthClient.create();
        let identity = authClient.getIdentity();
        if (identity.getPrincipal().isAnonymous()) {
            set(undefined);
        } else {
            set(identity);
        }
    };

    const login = async () => {
        let authClient = await AuthClient.create();
        await authClient.login({
            maxTimeToLive: BigInt(30) * BigInt(24) * BigInt(3_600_000_000_000), // 30 days
            identityProvider:
                process.env.DFX_NETWORK === "ic"
                    ? "https://identity.ic0.app"
                    : `http://localhost:4943/?canisterId=rdmx6-jaaaa-aaaaa-aaadq-cai`,
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
        let authClient = await AuthClient.create();
        try {
            await authClient.logout();
        } finally {
            await refresh();
        }
    }

    refresh();

    return {
        subscribe,
        login,
        logout,
    };
}

// Create a store
export const identityStore = createIdentityStore();
