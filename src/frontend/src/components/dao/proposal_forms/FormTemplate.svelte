<script lang="ts">
  import { navigate } from "svelte-routing";
  import { CreateWorldProposalRequest } from "../../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../../ic-agent/Main";
  import { proposalStore } from "../../../stores/ProposalStore";
  import LoadingButton from "../../common/LoadingButton.svelte";

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
    proposalStore.fetchPage(1);
    navigate("/dao");
  };
</script>

<div>
  <slot />
  <div class="flex justify-center mt-5">
    <LoadingButton onClick={createProposal}>Create</LoadingButton>
  </div>
</div>
