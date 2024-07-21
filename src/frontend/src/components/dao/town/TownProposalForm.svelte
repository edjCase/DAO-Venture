<script lang="ts">
    import { Select } from "flowbite-svelte";
    import ChangeNameForm from "./proposal_forms/ChangeNameForm.svelte";
    import ChangeFlagForm from "./proposal_forms/ChangeFlagForm.svelte";
    import ChangeMottoForm from "./proposal_forms/ChangeMottoForm.svelte";
    import MotionForm from "./proposal_forms/MotionForm.svelte";

    export let townId: bigint;

    let proposalTypes = [
        {
            value: "motion",
            name: "Motion",
            component: MotionForm,
        },
        {
            value: "changeName",
            name: "Change Town Name",
            component: ChangeNameForm,
        },
        {
            value: "changeFlag",
            name: "Change Town Flag",
            component: ChangeFlagForm,
        },
        {
            value: "changeMotto",
            name: "Change Town Motto",
            component: ChangeMottoForm,
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
<svelte:component this={selectedProposal.component} {townId} />
