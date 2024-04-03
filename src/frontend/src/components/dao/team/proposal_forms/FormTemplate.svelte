<script lang="ts">
    import { teamsAgentFactory } from "../../../../ic-agent/Teams";
    import { proposalStore } from "../../../../stores/ProposalStore";
    import LoadingButton from "../../../common/LoadingButton.svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/teams";

    export let teamId: bigint;
    export let generateProposal: () => ProposalContent | string;

    let createProposal = async () => {
        let proposal = generateProposal();
        if (typeof proposal === "string") {
            console.error("Error creating proposal: ", proposal);
            return;
        }
        console.log("Creating proposal: ", proposal);
        let teamsAgent = await teamsAgentFactory();
        let result = await teamsAgent.createProposal(teamId, {
            content: proposal,
        });
        if ("ok" in result) {
            console.log(`Created Team Proposal: `, result.ok);
            proposalStore.refetchTeamProposal(teamId, result.ok);
        } else {
            console.error("Error creating proposal: ", result);
        }
    };
</script>

<div>
    <slot />
    <LoadingButton onClick={createProposal}>Create Proposal</LoadingButton>
</div>
