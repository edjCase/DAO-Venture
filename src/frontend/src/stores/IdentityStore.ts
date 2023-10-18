import type { Identity } from '@dfinity/agent';
import { AuthClient } from '@dfinity/auth-client';
import { onMount } from 'svelte';
import { writable } from 'svelte/store';


async function fetchIdentity() {
    // Your async logic here
    let authClient = await AuthClient.create();
    return await authClient.getIdentity();
}

function createIdentityStore() {
    const { subscribe, set } = writable<Identity>(null);

    fetchIdentity().then(identity => {
        set(identity);
    });

    return {
        subscribe,
        set
    };
}

// Create a store
export const identityStore = createIdentityStore();
