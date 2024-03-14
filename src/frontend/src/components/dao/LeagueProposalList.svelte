<script lang="ts">
    import ProposalList from "./ProposalList.svelte";
    import { proposalStore } from "../../stores/ProposalStore";
    import { Proposal as ProposalType } from "../../ic-agent/declarations/league";
    import { onDestroy } from "svelte";
    import LeagueProposal from "./LeagueProposal.svelte";

    let proposals: ProposalType[] = [];

    let unsubscribeToTeamProposals = proposalStore.subscribeToLeague(
        (updatedProposals) => {
            proposals = updatedProposals;
        },
    );
    onDestroy(() => {
        unsubscribeToTeamProposals();
    });

    let getProposal = (proposalId: bigint): ProposalType => {
        let proposal = proposals.find((p) => p.id == proposalId);
        if (proposal) {
            return proposal;
        }
        throw new Error("Proposal not found");
    };
</script>

{proposals.length}

<ProposalList {proposals} let:proposalId>
    <LeagueProposal proposal={getProposal(proposalId)} />
</ProposalList>
