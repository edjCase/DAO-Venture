<script lang="ts">
    import { mainAgentFactory } from "../../../../ic-agent/Main";
    import { proposalStore } from "../../../../stores/ProposalStore";
    import LoadingButton from "../../../common/LoadingButton.svelte";
    import { CreateLeagueProposalRequest } from "../../../../ic-agent/declarations/main";

    export let generateProposal: () => CreateLeagueProposalRequest | string;

    let createProposal = async () => {
        let proposal = generateProposal();
        if (typeof proposal === "string") {
            console.error("Error creating league proposal: ", proposal);
            return;
        }
        console.log("Creating league proposal: ", proposal);
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.createLeagueProposal(proposal);
        if ("ok" in result) {
            console.log(`Created League Proposal: `, result.ok);
            proposalStore.refetchLeagueProposal(result.ok);
        } else {
            console.error("Error creating league proposal: ", result);
        }
    };
</script>

<div>
    <slot />
    <div class="flex justify-center mt-5">
        <LoadingButton onClick={createProposal}>Create</LoadingButton>
    </div>
</div>
