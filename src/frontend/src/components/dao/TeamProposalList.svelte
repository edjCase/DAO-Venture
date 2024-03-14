<script lang="ts">
    import ProposalList from "./ProposalList.svelte";
    import { proposalStore } from "../../stores/ProposalStore";
    import { Proposal } from "../../ic-agent/declarations/team";
    import { onDestroy } from "svelte";
    import TeamProposal from "./TeamProposal.svelte";

    export let teamId: bigint;

    let proposals: Proposal[] = [];

    let unsubscribeToTeamProposals = proposalStore.subscribeToTeam(
        teamId,
        (updatedProposals) => {
            proposals = updatedProposals;
        },
    );
    onDestroy(() => {
        unsubscribeToTeamProposals();
    });

    let getProposal = (proposalId: bigint): Proposal => {
        let proposal = proposals.find((p) => p.id == proposalId);
        if (proposal) {
            return proposal;
        }
        throw new Error("Proposal not found");
    };
</script>

<ProposalList {proposals} let:proposalId>
    <TeamProposal {teamId} proposal={getProposal(proposalId)} />
</ProposalList>
