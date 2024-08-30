<script lang="ts">
  import { Select } from "flowbite-svelte";
  import MotionForm from "./proposal_forms/MotionForm.svelte";
  import ModifyGameContentForm from "./proposal_forms/ModifyGameContentForm.svelte";

  let proposalTypes = [
    {
      value: "motion",
      name: "Motion",
      component: MotionForm,
    },
    {
      value: "modifyGameContent",
      name: "Modify Game Content",
      component: ModifyGameContentForm,
    },
  ];
  let selectedProposalType: string = proposalTypes[0].value;

  let selectedProposal = proposalTypes[0];
  $: {
    let c = proposalTypes.find((pt) => pt.value === selectedProposalType);
    if (c) {
      selectedProposal = c;
    }
  }
</script>

<div class="text-3xl text-center mb-5">Create Proposal</div>
<div class="mb-2">
  <Select items={proposalTypes} bind:value={selectedProposalType} />
</div>
<svelte:component this={selectedProposal.component} />
