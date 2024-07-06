import { Writable, writable } from "svelte/store";
import { LeagueProposal, TeamProposal } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";
import { toJsonString } from "../utils/StringUtil";


export const proposalStore = (() => {
    let leagueStore = writable<LeagueProposal[]>([]);
    let teamStores = new Map<bigint, Writable<TeamProposal[]>>();



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

    const getOrCreateTeamStore = (teamId: bigint) => {
        let store = teamStores.get(teamId);
        if (!store) {
            store = writable<TeamProposal[]>([]);
            teamStores.set(teamId, store);
            refetchTeamProposals(teamId);
        };
        return store;
    };

    const refetchTeamProposal = async (teamId: bigint, proposalId: bigint) => {
        let store = getOrCreateTeamStore(teamId);
        let mainAgent = await mainAgentFactory();
        let proposalResult = await mainAgent
            .getTeamProposal(teamId, proposalId);
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
            throw new Error("Error fetching team proposal: " + toJsonString(proposalResult));
        }
    }

    const refetchTeamProposals = async (teamId: bigint) => {
        let store = getOrCreateTeamStore(teamId);
        let mainAgent = await mainAgentFactory();
        let proposals = await mainAgent
            .getTeamProposals(teamId, BigInt(999), BigInt(0)); // TODO
        if ('ok' in proposals) {
            store.set(proposals.ok.data);
        } else {
            throw new Error("Error fetching team proposals: " + toJsonString(proposals));
        }
    };

    const subscribeToTeam = (teamId: bigint, callback: (value: TeamProposal[]) => void) => {
        let store = getOrCreateTeamStore(teamId);
        return store.subscribe(callback);
    }

    refetchLeagueProposals();

    return {
        subscribeToLeague,
        refetchLeagueProposals,
        refetchLeagueProposal,
        subscribeToTeam,
        refetchTeamProposals,
        refetchTeamProposal
    };
})();


