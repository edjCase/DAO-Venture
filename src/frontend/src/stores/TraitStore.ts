import { writable } from "svelte/store";
import { playersAgentFactory } from "../ic-agent/Players";
import { Trait } from "../ic-agent/declarations/players";


export const traitStore = (() => {
    const { subscribe, set } = writable<Trait[]>([]);

    const refetch = () => {
        playersAgentFactory()
            .getTraits()
            .then((traits) => {
                set(traits);
            });
    };

    refetch();

    return {
        subscribe,
        refetch
    };
})();


