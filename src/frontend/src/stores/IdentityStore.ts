import { AuthClient } from '@dfinity/auth-client';
import { Principal } from '@dfinity/principal';
import { writable } from 'svelte/store';
import { Bool } from '../models/Season';
import { leagueAgentFactory } from '../ic-agent/League';
import { Identity as DfinityIdentity } from '@dfinity/agent';


type Identity = {
    id: Principal;
    isAdmin: Bool;
    identity: DfinityIdentity;
};

function createIdentityStore() {
    const { subscribe, set } = writable<Identity | undefined>();


    const refresh = async () => {
        let authClient = await AuthClient.create();
        let identity = authClient.getIdentity();
        let id = identity.getPrincipal();
        if (id.isAnonymous()) {
            set(undefined);
        } else {
            set({
                id: id,
                isAdmin: false,
                identity: identity,
            });
            let userInfo = await leagueAgentFactory()
                .getUserInfo();
            let isAdmin = false;
            if (userInfo && userInfo.length >= 1) {
                isAdmin = userInfo[0]!.isAdmin;
            }
            if (isAdmin) {
                set({
                    id: id,
                    isAdmin: true,
                    identity: identity,
                });
            }
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
