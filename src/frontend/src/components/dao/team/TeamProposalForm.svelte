<script lang="ts">
    import { Select } from "flowbite-svelte";
    import TrainPositionForm from "./proposal_forms/TrainPositionForm.svelte";
    import ChangeNameForm from "./proposal_forms/ChangeNameForm.svelte";
    import ChangeColorForm from "./proposal_forms/ChangeColorForm.svelte";
    import ChangeLogoForm from "./proposal_forms/ChangeLogoForm.svelte";
    import ChangeMottoForm from "./proposal_forms/ChangeMottoForm.svelte";
    import ChangeDescriptionForm from "./proposal_forms/ChangeDescriptionForm.svelte";
    import ModifyLinkForm from "./proposal_forms/ModifyLinkForm.svelte";
    import SwapPositionsForm from "./proposal_forms/SwapPositionsForm.svelte";
    import MotionForm from "./proposal_forms/MotionForm.svelte";

    export let teamId: bigint;

    let proposalTypes = [
        {
            value: "motion",
            name: "Motion",
            component: MotionForm,
        },
        {
            value: "train",
            name: "Train Player",
            component: TrainPositionForm,
        },
        {
            value: "changeName",
            name: "Change Team Name",
            component: ChangeNameForm,
        },
        {
            value: "changeColor",
            name: "Change Team Color",
            component: ChangeColorForm,
        },
        {
            value: "changeLogo",
            name: "Change Team Logo",
            component: ChangeLogoForm,
        },
        {
            value: "changeMotto",
            name: "Change Team Motto",
            component: ChangeMottoForm,
        },
        {
            value: "changeDescription",
            name: "Change Team Description",
            component: ChangeDescriptionForm,
        },
        {
            value: "Modify Link",
            name: "Modify Team Link",
            component: ModifyLinkForm,
        },
        {
            value: "swapPlayerPositions",
            name: "Swap Positions",
            component: SwapPositionsForm,
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
<svelte:component this={selectedProposal.component} {teamId} />
