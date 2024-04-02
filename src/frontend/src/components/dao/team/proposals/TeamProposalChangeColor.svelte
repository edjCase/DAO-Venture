<script lang="ts">
    import { Input, Label, Range } from "flowbite-svelte";
    import { teamsAgentFactory } from "../../../../ic-agent/Teams";
    import { proposalStore } from "../../../../stores/ProposalStore";
    import LoadingButton from "../../../common/LoadingButton.svelte";

    export let teamId: bigint;
    let red: number = 0;
    let green: number = 0;
    let blue: number = 0;

    let createProposal = async () => {
        let teamsAgent = await teamsAgentFactory();
        let result = await teamsAgent.createProposal(teamId, {
            content: {
                changeColor: {
                    color: [red, green, blue],
                },
            },
        });
        console.log("Create Proposal Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTeamProposal(teamId, result.ok);
        } else {
            console.error("Error creating proposal: ", result);
        }
    };

    $: rgb = `#${red.toString(16).padStart(2, "0")}${green
        .toString(16)
        .padStart(2, "0")}${blue.toString(16).padStart(2, "0")}`;
</script>

<div>
    <Label>Red</Label>
    <Range bind:value={red} min={0} max={255} />
    <Label>Green</Label>
    <Range bind:value={green} min={0} max={255} />
    <Label>Blue</Label>
    <Range bind:value={blue} min={0} max={255} />
    <div
        class="my-2"
        style="display: grid; grid-template-columns: auto auto; align-items: center; gap: 10px;"
    >
        <span
            class="mx-2"
            style="width: 50px; height: 50px; background-color: {rgb};"
        ></span>
        <Input disabled type="text" value={rgb} />
    </div>
    <LoadingButton onClick={createProposal}>Create Proposal</LoadingButton>
</div>
