import { writable } from "svelte/store";
import { playersAgentFactory } from "../ic-agent/Players";
import { Trait } from "../models/Trait";


export const traitStore = (() => {
    const { subscribe, set } = writable<Trait[] | undefined>();

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


