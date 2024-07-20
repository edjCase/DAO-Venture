import { Writable, writable } from "svelte/store";
import { LeagueProposal, TownProposal } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";
import { toJsonString } from "../utils/StringUtil";


export const proposalStore = (() => {
    let leagueStore = writable<LeagueProposal[]>([]);
    let townStores = new Map<bigint, Writable<TownProposal[]>>();



    const refetchLeagueProposal = async (proposalId: bigint) => {
        let mainAgent = await mainAgentFactory();
        let proposalResult = await mainAgent.getLeagueProposal(proposalId);
        let proposal: LeagueProposal;
        if ('ok' in proposalResult) {
            proposal = proposalResult.ok;
        } else {
            throw new Error("Error fetching proposal " + proposalId + ": " + toJsonString(proposalResult));
        }
        leagueStore.update((current) => {
            let index = current.findIndex(p => p.id === proposalId);
            if (index >= 0) {
                current[index] = proposal;
            } else {
                current.push(proposal);
            }
            return current;
        });
    }

    const refetchLeagueProposals = async () => {
        let mainAgent = await mainAgentFactory();
        let proposalsResult = await mainAgent.getLeagueProposals(BigInt(999), BigInt(0)); // TODO
        if ('ok' in proposalsResult) {
            leagueStore.set(proposalsResult.ok.data);
        } else {
            throw new Error("Error fetching proposals: " + toJsonString(proposalsResult));
        }
    };

    const subscribeToLeague = (callback: (value: LeagueProposal[]) => void) => {
        return leagueStore.subscribe(callback);
    }

    const getOrCreateTownStore = (townId: bigint) => {
        let store = townStores.get(townId);
        if (!store) {
            store = writable<TownProposal[]>([]);
            townStores.set(townId, store);
            refetchTownProposals(townId);
        };
        return store;
    };

    const refetchTownProposal = async (townId: bigint, proposalId: bigint) => {
        let store = getOrCreateTownStore(townId);
        let mainAgent = await mainAgentFactory();
        let proposalResult = await mainAgent
            .getTownProposal(townId, proposalId);
        if ('ok' in proposalResult) {
            let proposal = proposalResult.ok;
            store.update((current) => {
                let index = current.findIndex(p => p.id === proposalId);
                if (index >= 0) {
                    current[index] = proposal;
                } else {
                    current.push(proposal);
                }
                return current;
            });
        } else {
            throw new Error("Error fetching town proposal: " + toJsonString(proposalResult));
        }
    }

    const refetchTownProposals = async (townId: bigint) => {
        let store = getOrCreateTownStore(townId);
        let mainAgent = await mainAgentFactory();
        let proposals = await mainAgent
            .getTownProposals(townId, BigInt(999), BigInt(0)); // TODO
        if ('ok' in proposals) {
            store.set(proposals.ok.data);
        } else {
            throw new Error("Error fetching town proposals: " + toJsonString(proposals));
        }
    };

    const subscribeToTown = (townId: bigint, callback: (value: TownProposal[]) => void) => {
        let store = getOrCreateTownStore(townId);
        return store.subscribe(callback);
    }

    refetchLeagueProposals();

    return {
        subscribeToLeague,
        refetchLeagueProposals,
        refetchLeagueProposal,
        subscribeToTown,
        refetchTownProposals,
        refetchTownProposal
    };
})();


