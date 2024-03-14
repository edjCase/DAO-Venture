import { Writable, writable } from "svelte/store";
import { Proposal as TeamProposal } from "../ic-agent/declarations/teams";
import { Proposal as LeagueProposal } from "../ic-agent/declarations/league";
import { teamsAgentFactory } from "../ic-agent/Teams";
import { leagueAgentFactory } from "../ic-agent/League";
import { toJsonString } from "../utils/JsonUtil";


export const proposalStore = (() => {
    let leagueStore = writable<LeagueProposal[]>([]);
    let teamStores = new Map<bigint, Writable<TeamProposal[]>>();



    const refetchLeagueProposal = async (proposalId: bigint) => {
        let proposalResult = await leagueAgentFactory().getProposal(proposalId);
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
        let proposalsResult = await leagueAgentFactory().getProposals();
        if ('ok' in proposalsResult) {
            leagueStore.set(proposalsResult.ok);
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
        let proposalResult = await teamsAgentFactory().getProposal(teamId, proposalId);
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
        let proposals = await teamsAgentFactory().getProposals(teamId);
        if ('ok' in proposals) {
            store.set(proposals.ok);
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


