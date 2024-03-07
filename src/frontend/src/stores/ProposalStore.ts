import { Writable, writable } from "svelte/store";
import { Proposal } from "../ic-agent/declarations/team";
import { teamAgentFactory } from "../ic-agent/Team";
import { Principal } from "@dfinity/principal";



export const proposalStore = (() => {
    let teamStores = new Map<string, Writable<Proposal[]>>();

    const getOrCreateTeamStore = (teamId: string | Principal) => {
        if (teamId instanceof Principal) {
            teamId = teamId.toText();
        }
        let store = teamStores.get(teamId);
        if (!store) {
            store = writable<Proposal[]>([]);
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

    const subscribeToTeam = (teamId: string | Principal, callback: (value: Proposal[]) => void) => {
        let store = getOrCreateTeamStore(teamId);
        return store.subscribe(callback);
    }

    return {
        subscribeToTeam,
        refetchTeamProposals,
        refetchTeamProposal
    };
})();


