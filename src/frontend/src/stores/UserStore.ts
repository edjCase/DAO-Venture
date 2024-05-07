import { Principal } from '@dfinity/principal';
import { Writable, writable } from 'svelte/store';
import { usersAgentFactory } from '../ic-agent/Users';
import { GetUserResult, User, UserStats } from '../ic-agent/declarations/users';
import { toJsonString } from '../utils/StringUtil';
import { leagueAgentFactory } from '../ic-agent/League';
import { BenevolentDictatorState } from '../ic-agent/declarations/league';

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
        let usersAgent = await usersAgentFactory();
        let result: GetUserResult = await usersAgent.get(userId);
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
        let usersAgent = await usersAgentFactory();
        let result = await usersAgent.setFavoriteTeam(userId, teamId);
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
        let usersAgent = await usersAgentFactory();
        let result = await usersAgent.getStats();
        if ('ok' in result) {
            userStats.set(result.ok);
        } else {
            console.log("Error getting user stats", result);
        }
    };

    const refreshBdfnState = async () => {
        let leagueAgent = await leagueAgentFactory();
        let state = await leagueAgent.getBenevolentDictatorState();
        bdfnState.set(state);
    }

    const subscribeBdfnState = async (callback: (bdfnState: BenevolentDictatorState) => void) => {
        bdfnState.subscribe(callback);
    };

    const claimBdfnRole = async () => {
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.claimBenevolentDictatorRole();
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