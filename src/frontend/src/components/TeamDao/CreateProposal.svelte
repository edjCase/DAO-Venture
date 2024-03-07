<script lang="ts">
    import { Principal } from "@dfinity/principal";
    import { Button, Input, Select } from "flowbite-svelte";
    import { teamAgentFactory } from "../../ic-agent/Team";
    import { proposalStore } from "../../stores/ProposalStore";

    export let teamId: string | Principal;

    let proposalTypes = [
        {
            value: "trainPlayer",
            name: "Train Player",
        },
    ];
    let selectedProposalType: string = proposalTypes[0].value;
    let selectedPlayerId: string | undefined;

    let skillTypes = [
        {
            value: "speed",
            name: "Speed",
        },
    ];
    let selectedSkillId = skillTypes[0].value;

    let createTrainPlayerProposal = async () => {
        if (selectedPlayerId === undefined) {
            console.log("No player selected");
            return;
        }
        let playerId = Number(selectedPlayerId);
        console.log("Creating train player proposal");
        let skill;
        // TODO auto-generate this?
        switch (selectedSkillId) {
            case "speed":
                skill = { speed: null };
                break;
            default:
                throw new Error("Unknown skill type: " + selectedSkillId);
        }

        let result = await teamAgentFactory(teamId).createProposal({
            content: {
                trainPlayer: {
                    playerId: playerId,
                    skill: skill,
                },
            },
        });
        console.log("Create Proposal Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTeamProposal(teamId, result.ok);
        }
    };
</script>

<div>Create Proposal</div>
<Select items={proposalTypes} bind:value={selectedProposalType} />

{#if selectedProposalType === "trainPlayer"}
    <div>
        <Select items={skillTypes} bind:value={selectedSkillId} />
        <Input
            type="text"
            placeholder="Player ID"
            bind:value={selectedPlayerId}
        />
        <Button on:click={createTrainPlayerProposal}>
            Create Train Player Proposal
        </Button>
    </div>
{/if}
