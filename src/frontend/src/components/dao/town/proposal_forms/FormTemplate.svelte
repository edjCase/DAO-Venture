<script lang="ts">
    import { mainAgentFactory } from "../../../../ic-agent/Main";
    import { proposalStore } from "../../../../stores/ProposalStore";
    import LoadingButton from "../../../common/LoadingButton.svelte";
    import { TownProposalContent } from "../../../../ic-agent/declarations/main";

    export let townId: bigint;
    export let generateProposal: () => TownProposalContent | string;

    let createProposal = async () => {
        let proposal = generateProposal();
        if (typeof proposal === "string") {
            console.error("Error creating proposal: ", proposal);
            return;
        }
        console.log("Creating proposal: ", proposal);
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.createTownProposal(townId, proposal);
        if ("ok" in result) {
            console.log(`Created Town Proposal: `, result.ok);
            proposalStore.refetchTownProposal(townId, result.ok);
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
