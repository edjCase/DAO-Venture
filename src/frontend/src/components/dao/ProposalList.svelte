<script lang="ts">
  import { proposalStore } from "../../stores/ProposalStore";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import LoadingButton from "../common/LoadingButton.svelte";
  import RefreshIcon from "../common/RefreshIcon.svelte";
  import { Accordion } from "flowbite-svelte";
  import ProposalAccordianItem from "./ProposalAccordianItem.svelte";
  import Button from "flowbite-svelte/Button.svelte";

  let { proposals, currentPage, totalPages, isLoading } = $proposalStore;

  $: ({ proposals, currentPage, totalPages, isLoading } = $proposalStore);

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

  let onRefresh = () => proposalStore.fetchPage(currentPage);

  $: if (currentPage === 1 && proposals.length === 0) {
    proposalStore.fetchPage(1);
  }
</script>

<div class="flex justify-between items-center mb-5">
  <div class="text-3xl text-center w-full">Latest Proposals</div>
  <div>
    <LoadingButton onClick={onRefresh} loading={isLoading}>
      <RefreshIcon />
    </LoadingButton>
  </div>
</div>

{#if proposals.length === 0}
  <div class="flex justify-center">
    <div class="text-3xl text-center flex-grow">No proposals found</div>
  </div>
{:else}
  <Accordion>
    {#each proposals as proposal}
      <ProposalAccordianItem {proposal} {onVote} />
    {/each}
  </Accordion>

  <div class="flex justify-between mt-5">
    <Button
      on:click={() => proposalStore.prevPage()}
      disabled={currentPage === 1}
    >
      Previous
    </Button>
    <span>Page {currentPage} of {totalPages}</span>
    <Button
      on:click={() => proposalStore.nextPage()}
      disabled={currentPage === totalPages}
    >
      Next
    </Button>
  </div>
{/if}
