<script lang="ts">
    import { mainAgentFactory } from "../../../../ic-agent/Main";
    import { proposalStore } from "../../../../stores/ProposalStore";
    import LoadingButton from "../../../common/LoadingButton.svelte";
    import { TeamProposalContent } from "../../../../ic-agent/declarations/main";

    export let teamId: bigint;
    export let generateProposal: () => TeamProposalContent | string;

    let createProposal = async () => {
        let proposal = generateProposal();
        if (typeof proposal === "string") {
            console.error("Error creating proposal: ", proposal);
            return;
        }
        console.log("Creating proposal: ", proposal);
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.createTeamProposal(teamId, proposal);
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
    <div class="flex justify-center mt-5">
        <LoadingButton onClick={createProposal}>Create</LoadingButton>
    </div>
</div>
