import { Principal } from '@dfinity/principal';
import { Writable, writable } from 'svelte/store';
import { usersAgentFactory } from '../ic-agent/Users';
import { GetUserResult, User } from '../ic-agent/declarations/users';
import { toJsonString } from '../utils/StringUtil';

function createUserStore() {
    const userStores = new Map<string, Writable<User>>();

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
        else if ('notFound' in result) {
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

    return {
        subscribeUser,
        refetchUser,
        setFavoriteTeam
    };
}

// Create a store
export const userStore = createUserStore();