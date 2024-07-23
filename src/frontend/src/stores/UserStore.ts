import { writable } from 'svelte/store';
import { mainAgentFactory } from '../ic-agent/Main';
import { GetUserResult, User, UserStats } from '../ic-agent/declarations/main';
import { toJsonString } from '../utils/StringUtil';
import { BenevolentDictatorState } from '../ic-agent/declarations/main';
import { Principal } from '@dfinity/principal';
import { getOrCreateAuthClient } from '../utils/AuthUtil';



function createUserStore() {
    let currentUserId: Principal | undefined = undefined;
    const currentUser = writable<User | undefined>(undefined);
    const userStats = writable<UserStats>();
    const bdfnState = writable<BenevolentDictatorState>();


    const refetchCurrentUser = async () => {
        if (!currentUserId) {
            return; // No user to fetch
        }
        let mainAgent = await mainAgentFactory();
        let result: GetUserResult = await mainAgent.getUser(currentUserId);
        if ('ok' in result) {
            currentUser.set(result.ok);
        }
        else if ('err' in result && 'notFound' in result.err) {
            let emptyUser: User = {
                id: currentUserId,
                level: BigInt(0),
                gold: BigInt(0),
                residency: []
            };
            currentUser.set(emptyUser);
        } else {
            throw new Error("Failed to get user: " + currentUserId + " " + toJsonString(result));
        }
    };

    const subscribeCurrentUser = (callback: (user: User | undefined) => void) => {
        return currentUser.subscribe(callback);
    };

    const subscribeStats = async (callback: (stats: UserStats | undefined) => void) => {
        userStats.subscribe(callback);
    };

    const refetchStats = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getUserStats();
        if ('ok' in result) {
            userStats.set(result.ok);
        } else {
            console.log("Error getting user stats", result);
        }
    };

    const refreshBdfnState = async () => {
        let mainAgent = await mainAgentFactory();
        let state = await mainAgent.getBenevolentDictatorState();
        bdfnState.set(state);
    }

    const subscribeBdfnState = async (callback: (bdfnState: BenevolentDictatorState) => void) => {
        bdfnState.subscribe(callback);
    };

    const claimBdfnRole = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.claimBenevolentDictatorRole();
        if ('ok' in result) {
            refreshBdfnState();
        } else {
            console.log("Error claiming BDFN role", result);
        }
    }


    const login = async () => {
        let authClient = await getOrCreateAuthClient();
        await authClient.login({
            maxTimeToLive: BigInt(30) * BigInt(24) * BigInt(3_600_000_000_000), // 30 days
            identityProvider:
                process.env.DFX_NETWORK === "ic"
                    ? `https://identity.ic0.app`
                    : `http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:` + process.env.LOCAL_NETWORK_PORT,
            onSuccess: async () => {
                console.log("Logged in");
                currentUserId = authClient.getIdentity().getPrincipal();
                await refetchCurrentUser();
            },
            onError: (err) => {
                console.error(err);
            }
        });
    };

    const logout = async () => {
        let authClient = await getOrCreateAuthClient();
        currentUserId = undefined;
        await authClient.logout();
        currentUser.set(undefined);
    };

    const checkForLogin = async () => {
        let authClient = await getOrCreateAuthClient();
        let identity = authClient.getIdentity();
        if (!identity.getPrincipal().isAnonymous()) {
            currentUserId = identity.getPrincipal();
            await refetchCurrentUser();
        } else {
            currentUserId = undefined;
        }
    }

    checkForLogin();
    refetchStats();
    refreshBdfnState();

    return {
        login,
        logout,
        subscribe: subscribeCurrentUser,
        refetchCurrentUser,
        subscribeStats,
        refetchStats,
        refreshBdfnState,
        subscribeBdfnState,
        claimBdfnRole
    };
}

// Create a store
export const userStore = createUserStore();