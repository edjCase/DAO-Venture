<script lang="ts">
    import { Select } from "flowbite-svelte";
    import TeamProposalTrain from "./proposal_forms/TrainPositionForm.svelte";
    import TeamProposalChangeName from "./proposal_forms/ChangeNameForm.svelte";
    import TeamProposalChangeColor from "./proposal_forms/ChangeColorForm.svelte";

    export let teamId: bigint;

    let proposalTypes = [
        {
            value: "train",
            name: "Train Player",
            component: TeamProposalTrain,
        },
        {
            value: "changeName",
            name: "Change Team Name",
            component: TeamProposalChangeName,
        },
        {
            value: "changeColor",
            name: "Change Team Color",
            component: TeamProposalChangeColor,
        },
    ];
    let selectedProposalType: string = proposalTypes[0].value;

    let SelectedComponent = proposalTypes[0].component;
    $: {
        let c = proposalTypes.find((pt) => pt.value === selectedProposalType);
        if (c) {
            SelectedComponent = c.component;
        }
    }
</script>

<div class="text-3xl text-center">Create Proposal</div>
<Select items={proposalTypes} bind:value={selectedProposalType} />
<svelte:component this={SelectedComponent} {teamId} />
