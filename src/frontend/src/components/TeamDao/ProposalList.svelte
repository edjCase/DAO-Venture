<script lang="ts">
    import { onDestroy } from "svelte";
    import { proposalStore } from "../../stores/ProposalStore";
    import { Principal } from "@dfinity/principal";
    import { Proposal as ProposalType } from "../../ic-agent/declarations/team";
    import Proposal from "./Proposal.svelte";
    import { Select } from "flowbite-svelte";

    export let teamId: string | Principal;

    let proposals: ProposalType[] = [];
    let filteredProposals: ProposalType[] = [];
    let statusFilter = "open";

    let statuses = [
        {
            value: "all",
            name: "All",
        },
        {
            value: "open",
            name: "Open",
        },
        {
            value: "closed",
            name: "Closed",
        },
    ];

    let unsubscribeToTeamProposals = proposalStore.subscribeToTeam(
        teamId,
        (updatedProposals) => {
            proposals = updatedProposals;
        },
    );
    $: {
        filteredProposals = proposals.filter(
            (proposal) =>
                statusFilter === "all" || statusFilter in proposal.status,
        );
    }

    onDestroy(() => {
        unsubscribeToTeamProposals();
    });
</script>

<Select items={statuses} bind:value={statusFilter} />

{#each filteredProposals as proposal}
    <div>
        <Proposal {teamId} {proposal} />
    </div>
{/each}
