<script lang="ts">
    import { Button, Input, Select } from "flowbite-svelte";
    import CreateProposal from "./CreateProposal.svelte";
    import { proposalStore } from "../../stores/ProposalStore";
    import { teamsAgentFactory } from "../../ic-agent/Teams";

    export let teamId: bigint;

    let selectedPlayerId: string | undefined;
    let newName: string | undefined;

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
        let teamsAgent = await teamsAgentFactory();

        let result = await teamsAgent.createProposal(teamId, {
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

    let createNewNameProposal = async () => {
        if (newName === undefined) {
            console.log("No new name selected");
            return;
        }
        let teamsAgent = await teamsAgentFactory();
        let result = await teamsAgent.createProposal(teamId, {
            content: {
                changeName: {
                    name: newName,
                },
            },
        });
        console.log("Create Proposal Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTeamProposal(teamId, result.ok);
        }
    };
</script>

<CreateProposal let:selectedProposalType>
    {#if selectedProposalType === "trainPlayer"}
        <div>
            <Select items={skillTypes} bind:value={selectedSkillId} />
            <Input
                type="text"
                placeholder="Player ID"
                bind:value={selectedPlayerId}
            />
            <Button on:click={createTrainPlayerProposal}>
                Create Proposal
            </Button>
        </div>
    {:else if selectedProposalType === "changeName"}
        <div>
            <Input type="text" placeholder="New Name" bind:value={newName} />
            <Button on:click={createNewNameProposal}>Create Proposal</Button>
        </div>
    {:else}
        NOT IMPLEMENTED: {selectedProposalType}
    {/if}
</CreateProposal>
