import { Principal } from '@dfinity/principal';
import { Writable, writable } from 'svelte/store';
import { mainAgentFactory } from '../ic-agent/Main';
import { GetUserResult, User, UserStats } from '../ic-agent/declarations/main';
import { toJsonString } from '../utils/StringUtil';
import { BenevolentDictatorState } from '../ic-agent/declarations/main';

function createUserStore() {
    const userStores = new Map<string, Writable<User>>();
    const userStats = writable<UserStats>();
    const bdfnState = writable<BenevolentDictatorState>();


    const refetchUser = async (userId: Principal) => {
        let store = await getOrCreateStore(userId);
        let user = await get(userId);
        store.set(user);
    };

    const getOrCreateStore = async (userId: Principal) => {
        if (!userStores.has(userId.toText())) {
            let user = await get(userId);
            if (user) {
                userStores.set(userId.toText(), writable<User>(user));
            }
        }
        return userStores.get(userId.toText())!;
    };

    const get = async (userId: Principal) => {
        let mainAgent = await mainAgentFactory();
        let result: GetUserResult = await mainAgent.getUser(userId);
        if ('ok' in result) {
            return result.ok;
        }
        else if ('err' in result && 'notFound' in result.err) {
            let emptyUser: User = {
                id: userId,
                points: BigInt(0),
                team: []
            };
            return emptyUser;
        } else {
            throw new Error("Failed to get user: " + userId + " " + toJsonString(result));
        }
    }

    const subscribeUser = async (userId: Principal, callback: (user: User) => void) => {
        let store = await getOrCreateStore(userId);
        return store.subscribe(callback);
    };

    const setFavoriteTeam = async (userId: Principal, teamId: bigint) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.setFavoriteTeam(userId, teamId);
        if ('ok' in result) {
            refetchUser(userId);
        }
        return result;
    };

    const subscribeStats = async (callback: (stats: UserStats) => void) => {
        userStats.subscribe(s => {
            if (s) {
                callback(s);
            }
        });
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

    refetchStats();
    refreshBdfnState();

    return {
        subscribeUser,
        refetchUser,
        setFavoriteTeam,
        subscribeStats,
        refetchStats,
        refreshBdfnState,
        subscribeBdfnState,
        claimBdfnRole
    };
}

// Create a store
export const userStore = createUserStore();