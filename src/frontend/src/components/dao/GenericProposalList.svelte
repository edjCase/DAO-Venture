<script lang="ts">
    import { Accordion } from "flowbite-svelte";
    import { ProposalType } from "./GenericProposal.svelte";
    import RefreshIcon from "../common/RefreshIcon.svelte";
    import LoadingButton from "../common/LoadingButton.svelte";
    import GenericProposalAccordianItem from "./GenericProposalAccordianItem.svelte";

    export let proposals: ProposalType[];
    export let onVote: (proposalId: bigint, vote: boolean) => Promise<void>;
    export let onRefresh: () => Promise<void>;

    $: proposals = proposals.sort((a, b) => {
        return Number(b.timeStart - a.timeStart);
    });
</script>

<div class="flex justify-between items-center mb-5">
    <div class="text-3xl text-center w-full">Latest Proposals</div>
    <div>
        <LoadingButton onClick={onRefresh}>
            <RefreshIcon />
        </LoadingButton>
    </div>
</div>
{#if proposals.length === 0}
    <div class="flex justify-center">
        <div class="text-3xl text-center flex-grow">-</div>
    </div>
{:else}
    <Accordion>
        {#each proposals as proposal}
            <GenericProposalAccordianItem {proposal} {onVote} />
        {/each}
    </Accordion>
{/if}
