import { Principal } from '@dfinity/principal';
import { writable } from 'svelte/store';
import { usersAgentFactory } from '../ic-agent/Users';
import { GetUserResult, User } from '../ic-agent/declarations/users';

function createUserStore() {
    const { subscribe, set, update } = writable<User[]>([]); // TODO better way to only have subset of users?

    const updateUser = (userId: Principal, user: User | undefined) => {
        update((users) => {
            let index = users.findIndex((u) => u.id.toText() === userId.toText());
            if (index >= 0) {
                if (user === undefined) {
                    users.splice(index, 1);
                } else {
                    users[index] = user;
                }
            } else {
                if (user !== undefined) {
                    users.push(user);
                }
            }
            return users;
        });
    };

    const refetch = async () => {
        let users = await usersAgentFactory()
            .getAll();
        set(users);
    }

    const refetchUser = async (userId: Principal) => {
        usersAgentFactory()
            .get(userId)
            .then((result: GetUserResult) => {
                if ('ok' in result) {
                    updateUser(userId, result.ok);
                } else if ('notFound' in result) {
                    updateUser(userId, undefined);
                } else {
                    console.log("Error getting user: ", result)
                }
            });
    };

    const setFavoriteTeam = async (userId: Principal, teamId: bigint) => {
        await usersAgentFactory()
            .setFavoriteTeam(userId, teamId);
        refetchUser(userId);
    };

    const subscribeUser = (userId: Principal, callback: (value: User) => void) => {
        refetchUser(userId);
        return subscribe((users) => {
            let user = users.find((u) => u.id.toText() === userId.toText());
            if (user) {
                callback(user);
            }
        });
    };

    return {
        subscribe,
        refetch,
        subscribeUser,
        refetchUser,
        setFavoriteTeam
    };
}

// Create a store
export const userStore = createUserStore();
