import { writable } from "svelte/store";
import { Trait } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";



export const traitStore = (() => {
    const { subscribe, set } = writable<Trait[] | undefined>();

    const refetch = async () => {
        let mainAgent = await mainAgentFactory();
        let traits = await mainAgent.getTraits();
        set(traits);
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


