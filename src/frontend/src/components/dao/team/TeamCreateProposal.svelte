<script lang="ts">
    import { Select } from "flowbite-svelte";
    import TeamProposalTrain from "./proposals/TeamProposalTrain.svelte";
    import TeamProposalChangeName from "./proposals/TeamProposalChangeName.svelte";
    import TeamProposalChangeColor from "./proposals/TeamProposalChangeColor.svelte";

    export let teamId: bigint;

    let proposalTypes = [
        {
            value: "train",
            name: "Train Player",
        },
        {
            value: "changeName",
            name: "Change Team Name",
        },
        {
            value: "changeColor",
            name: "Change Team Color",
        },
    ];
    let selectedProposalType: string = proposalTypes[0].value;
</script>

<div class="text-3xl text-center">Create Proposal</div>
<Select items={proposalTypes} bind:value={selectedProposalType} />
{#if selectedProposalType === "train"}
    <TeamProposalTrain {teamId} />
{:else if selectedProposalType === "changeName"}
    <TeamProposalChangeName {teamId} />
{:else if selectedProposalType == "changeColor"}
    <TeamProposalChangeColor {teamId} />
{:else}
    NOT IMPLEMENTED PROPOSAL TYPE: {selectedProposalType}
{/if}
