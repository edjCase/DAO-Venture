import { Writable, writable } from "svelte/store";
import { Proposal as TeamProposal } from "../ic-agent/declarations/team";
import { Proposal as LeagueProposal } from "../ic-agent/declarations/league";
import { teamAgentFactory } from "../ic-agent/Team";
import { Principal } from "@dfinity/principal";
import { leagueAgentFactory } from "../ic-agent/League";



export const proposalStore = (() => {
    let leagueStore = writable<LeagueProposal[]>([]);
    let teamStores = new Map<string, Writable<TeamProposal[]>>();



    const refetchLeagueProposal = async (proposalId: bigint) => {
        let proposalResult = await leagueAgentFactory().getProposal(proposalId);
        if (proposalResult.length === 0) {
            throw new Error("Proposal not found: " + proposalId + " for league");
        }
        let proposal = proposalResult[0];
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
        let proposals = await leagueAgentFactory().getProposals();
        leagueStore.set(proposals);
    };

    const subscribeToLeague = (callback: (value: LeagueProposal[]) => void) => {
        return leagueStore.subscribe(callback);
    }

    const getOrCreateTeamStore = (teamId: string | Principal) => {
        if (teamId instanceof Principal) {
            teamId = teamId.toText();
        }
        let store = teamStores.get(teamId);
        if (!store) {
            store = writable<TeamProposal[]>([]);
            teamStores.set(teamId, store);
            refetchTeamProposals(teamId);
        };
        return store;
    };

    const refetchTeamProposal = async (teamId: string | Principal, proposalId: bigint) => {
        let store = getOrCreateTeamStore(teamId);
        let proposalResult = await teamAgentFactory(teamId).getProposal(proposalId);
        if (proposalResult.length === 0) {
            throw new Error("Proposal not found: " + proposalId + " for team: " + teamId);
        }
        let proposal = proposalResult[0];
        store.update((current) => {
            let index = current.findIndex(p => p.id === proposalId);
            if (index >= 0) {
                current[index] = proposal;
            } else {
                current.push(proposal);
            }
            return current;
        });
    }

    const refetchTeamProposals = async (teamId: string | Principal) => {
        let store = getOrCreateTeamStore(teamId);
        let proposals = await teamAgentFactory(teamId).getProposals();
        store.set(proposals);
    };

    const subscribeToTeam = (teamId: string | Principal, callback: (value: TeamProposal[]) => void) => {
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


