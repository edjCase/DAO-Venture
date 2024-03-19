<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { ProposalStatusLogEntry } from "../../ic-agent/declarations/league";

    interface ProposalType {
        id: bigint;
        statusLog: ProposalStatusLogEntry[];
    }

    export let proposals: ProposalType[];
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
    $: {
        if (statusFilter === "all") {
            filteredProposals = proposals;
        } else if (statusFilter === "open") {
            filteredProposals = proposals.filter((proposal) => {
                return proposal.statusLog.length < 1; // TODO?
            });
        } else if (statusFilter === "closed") {
            filteredProposals = proposals.filter((proposal) => {
                return proposal.statusLog.length > 0; // TODO?
            });
        }
    }
</script>

<div class="flex justify-center">
    <div class="text-3xl text-center flex-grow">Proposals</div>
    <div class="w-24">
        <Select items={statuses} bind:value={statusFilter} />
    </div>
</div>
<div class="border rounded min-h-48">
    {#each filteredProposals as proposal}
        <div>
            <slot proposalId={proposal.id} />
        </div>
    {/each}
</div>
