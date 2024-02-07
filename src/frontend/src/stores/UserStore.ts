import { AuthClient } from '@dfinity/auth-client';
import { Principal } from '@dfinity/principal';
import { writable } from 'svelte/store';
import { Bool } from '../models/Season';
import { leagueAgentFactory } from '../ic-agent/League';
import { Identity } from '@dfinity/agent';


type User = {
    id: Principal;
    isAdmin: Bool;
    favoriteTeamId?: Principal;
    identity: Identity;
};

function createUserStore() {
    const { subscribe, set } = writable<User | undefined>();


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
            set({
                id: id,
                isAdmin: userInfo.isAdmin,
                favoriteTeamId: userInfo.favoriteTeamId.length == 0 ? undefined : userInfo.favoriteTeamId[0],
                identity: identity,
            });
        }
    };

    const login = async () => {
        let authClient = await AuthClient.create();
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
        let authClient = await AuthClient.create();
        try {
            await authClient.logout();
        } finally {
            await refresh();
        }
    };

    const setFavoriteTeam = async (teamId: Principal) => {
        await leagueAgentFactory()
            .setUserFavoriteTeam(teamId);
        refresh();
    };

    refresh();

    return {
        subscribe,
        login,
        logout,
        setFavoriteTeam
    };
}

// Create a store
export const userStore = createUserStore();
