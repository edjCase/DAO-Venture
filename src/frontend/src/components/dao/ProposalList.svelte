<script lang="ts">
    import { proposalStore } from "../../stores/ProposalStore";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import LoadingButton from "../common/LoadingButton.svelte";
    import RefreshIcon from "../common/RefreshIcon.svelte";
    import { Accordion } from "flowbite-svelte";
    import ProposalAccordianItem from "./ProposalAccordianItem.svelte";

    $: proposals = $proposalStore;

    let onVote = async (proposalId: bigint, vote: boolean) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.voteOnWorldProposal({
            proposalId: proposalId,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchById(proposalId);
        }
    };

    let onRefresh = async () => {
        await proposalStore.refetch();
    };
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
            <ProposalAccordianItem {proposal} {onVote} />
        {/each}
    </Accordion>
{/if}
