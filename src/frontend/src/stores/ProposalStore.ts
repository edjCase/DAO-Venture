// proposalStore.ts
import { writable } from "svelte/store";
import { WorldProposal } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";

const PAGE_SIZE = 5;

function createProposalStore() {
    const { subscribe, update } = writable<{
        proposals: WorldProposal[];
        currentPage: number;
        totalPages: number;
        isLoading: boolean;
    }>({
        proposals: [],
        currentPage: 1,
        totalPages: 1,
        isLoading: false
    });

    async function fetchPage(page: number) {
        update(state => ({ ...state, isLoading: true }));
        const mainAgent = await mainAgentFactory();
        const offset = BigInt((page - 1) * PAGE_SIZE);
        const proposalsResult = await mainAgent.getWorldProposals(BigInt(PAGE_SIZE), offset);

        update(state => ({
            ...state,
            proposals: proposalsResult.data,
            currentPage: page,
            totalPages: Math.ceil(Number(proposalsResult.totalCount) / PAGE_SIZE),
            isLoading: false
        }));
    }

    async function refetchById(proposalId: bigint) {
        const mainAgent = await mainAgentFactory();
        const proposalResult = await mainAgent.getWorldProposal(proposalId);
        if ('ok' in proposalResult) {
            update(state => {
                const index = state.proposals.findIndex(p => p.id === proposalId);
                if (index >= 0) {
                    state.proposals[index] = proposalResult.ok;
                }
                return state;
            });
        } else {
            console.error("Error fetching proposal", proposalId, proposalResult);
        }
    }

    return {
        subscribe,
        fetchPage,
        refetchById,
        nextPage: () => update(state => {
            if (state.currentPage < state.totalPages) {
                fetchPage(state.currentPage + 1);
            }
            return state;
        }),
        prevPage: () => update(state => {
            if (state.currentPage > 1) {
                fetchPage(state.currentPage - 1);
            }
            return state;
        })
    };
}

export const proposalStore = createProposalStore();