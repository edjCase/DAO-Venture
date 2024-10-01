<script lang="ts">
  import { CreateWorldProposalRequest } from "../../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../../ic-agent/Main";
  import { proposalStore } from "../../../stores/ProposalStore";
  import LoadingButton from "../../common/LoadingButton.svelte";
  import { Button } from "flowbite-svelte";

  export let generateProposal: () => CreateWorldProposalRequest | string;

  let createProposal = async () => {
    let proposal = generateProposal();
    if (typeof proposal === "string") {
      console.error("Error creating proposal: ", proposal);
      return;
    }
    console.log("Creating proposal: ", proposal);
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.createWorldProposal(proposal);
    if ("ok" in result) {
      console.log(`Created Proposal: `, result.ok);
      proposalStore.refetchById(result.ok);
    } else {
      console.error("Error creating proposal: ", result);
    }
    resetPage();
  };

  let resetPage = () => {
    // TODO how to use routing for reload?
    window.location.reload();
  };
</script>

<div>
  <slot />
  <div class="flex justify-center mt-5 gap-2">
    <LoadingButton onClick={createProposal}>Create</LoadingButton>
    <Button on:click={resetPage} color="red">Cancel</Button>
  </div>
</div>
