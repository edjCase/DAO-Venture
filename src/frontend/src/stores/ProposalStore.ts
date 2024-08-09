import { writable } from "svelte/store";
import { WorldProposal } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";
import { toJsonString } from "../utils/StringUtil";


export const proposalStore = (() => {
    let worldStore = writable<WorldProposal[]>([]);

    const refetchById = async (proposalId: bigint) => {
        let mainAgent = await mainAgentFactory();
        let proposalResult = await mainAgent.getWorldProposal(proposalId);
        let proposal: WorldProposal;
        if ('ok' in proposalResult) {
            proposal = proposalResult.ok;
        } else {
            throw new Error("Error fetching proposal " + proposalId + ": " + toJsonString(proposalResult));
        }
        worldStore.update((current) => {
            let index = current.findIndex(p => p.id === proposalId);
            if (index >= 0) {
                current[index] = proposal;
            } else {
                current.push(proposal);
            }
            return current;
        });
    }

    const refetch = async () => {
        let mainAgent = await mainAgentFactory();
        let proposalsResult = await mainAgent.getWorldProposals(BigInt(999), BigInt(0)); // TODO
        worldStore.set(proposalsResult.data);
    };

    const subscribe = (callback: (value: WorldProposal[]) => void) => {
        return worldStore.subscribe(callback);
    }


    refetch();

    return {
        subscribe,
        refetch,
        refetchById,
    };
})();


