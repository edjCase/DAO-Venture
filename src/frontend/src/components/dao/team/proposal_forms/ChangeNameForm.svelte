<script lang="ts">
    import { Input } from "flowbite-svelte";
    import { teamsAgentFactory } from "../../../../ic-agent/Teams";
    import { proposalStore } from "../../../../stores/ProposalStore";
    import LoadingButton from "../../../common/LoadingButton.svelte";

    export let teamId: bigint;
    let newName: string | undefined;

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
        } else {
            console.error("Error creating proposal: ", result);
        }
    };
</script>

<div>
    <Input type="text" placeholder="New Name" bind:value={newName} />
    <LoadingButton onClick={createNewNameProposal}>
        Create Proposal
    </LoadingButton>
</div>
