<script lang="ts">
    import { CreateWorldProposalRequest } from "../../../ic-agent/declarations/main";
    import { mainAgentFactory } from "../../../ic-agent/Main";
    import { proposalStore } from "../../../stores/ProposalStore";
    import LoadingButton from "../../common/LoadingButton.svelte";

    export let generateProposal: () => CreateWorldProposalRequest | string;

    let createProposal = async () => {
        let proposal = generateProposal();
        if (typeof proposal === "string") {
            console.error("Error creating world proposal: ", proposal);
            return;
        }
        console.log("Creating world proposal: ", proposal);
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.createWorldProposal(proposal);
        if ("ok" in result) {
            console.log(`Created World Proposal: `, result.ok);
            proposalStore.refetchById(result.ok);
        } else {
            console.error("Error creating world proposal: ", result);
        }
    };
</script>

<div>
    <slot />
    <div class="flex justify-center mt-5">
        <LoadingButton onClick={createProposal}>Create</LoadingButton>
    </div>
</div>
