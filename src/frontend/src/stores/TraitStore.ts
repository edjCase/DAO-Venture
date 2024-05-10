import { writable } from "svelte/store";
import { Trait } from "../ic-agent/declarations/teams";
import { teamsAgentFactory } from "../ic-agent/Teams";



export const traitStore = (() => {
    const { subscribe, set } = writable<Trait[] | undefined>();

    const refetch = async () => {
        let teamsAgent = await teamsAgentFactory();
        let traits = await teamsAgent.getTraits();
        set(traits);
    };
    refetch();

    return {
        subscribe,
        refetch
    };
})();


