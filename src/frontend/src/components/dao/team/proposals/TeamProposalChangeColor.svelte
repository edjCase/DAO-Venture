<script lang="ts">
    import { Label, Range } from "flowbite-svelte";
    import { teamsAgentFactory } from "../../../../ic-agent/Teams";
    import { proposalStore } from "../../../../stores/ProposalStore";
    import LoadingButton from "../../../common/LoadingButton.svelte";
    import RgbColor from "../../../common/RgbColor.svelte";

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
</script>

<div>
    <Label>Red</Label>
    <Range bind:value={red} min={0} max={255} />
    <Label>Green</Label>
    <Range bind:value={green} min={0} max={255} />
    <Label>Blue</Label>
    <Range bind:value={blue} min={0} max={255} />
    <RgbColor {red} {green} {blue} />
    <LoadingButton onClick={createProposal}>Create Proposal</LoadingButton>
</div>
