import { AuthClient } from '@dfinity/auth-client';
import { Principal } from '@dfinity/principal';
import { get, writable } from 'svelte/store';
import { usersAgentFactory } from '../ic-agent/Users';
import { Identity } from '@dfinity/agent';
import { leagueAgentFactory } from '../ic-agent/League';
import { GetUserResult, User } from '../ic-agent/declarations/users';


type UserContext = {
    id: Principal;
    user?: User;
    identity: Identity;
};
const authClientOptions = { idleOptions: { disableIdle: true } };

function createUserStore() {
    const { subscribe, set } = writable<UserContext | undefined>();
    const { subscribe: subscribeAdmins, set: setAdmins } = writable<Principal[]>([]);

    const refreshAdmins = async () => {
        let admins = await leagueAgentFactory()
            .getAdmins();
        setAdmins(admins);
    };


    const refresh = async () => {
        let authClient = await AuthClient.create(authClientOptions);
        let identity = authClient.getIdentity();
        let id = identity.getPrincipal();
        if (id.isAnonymous()) {
            set(undefined);
        } else {
            set({
                id: id,
                user: undefined,
                identity: identity,
            });
            usersAgentFactory()
                .get(id)
                .then((result: GetUserResult) => {
                    if ('ok' in result) {
                        set({
                            id: id,
                            user: result.ok,
                            identity: identity,
                        });
                    } else if ('notFound' in result) {
                        set({
                            id: id,
                            user: {
                                teamAssociation: [],
                                points: BigInt(0)
                            },
                            identity: identity,
                        });
                    } else {
                        console.log("Error getting user: ", result)
                    }
                });

        }
        refreshAdmins();
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

    const setFavoriteTeam = async (teamId: Principal) => {
        let user = get({ subscribe });
        if (user === undefined) {
            throw new Error("User not logged in, cannot set favorite team");
        }
        await usersAgentFactory()
            .setFavoriteTeam(user.id, teamId);
        refresh();
    };

    refresh();

    return {
        subscribe,
        subscribeAdmins,
        login,
        logout,
        setFavoriteTeam
    };
}

// Create a store
export const userStore = createUserStore();
