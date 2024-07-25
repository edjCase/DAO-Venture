<script lang="ts">
    import { TownProposalContent } from "../../../../ic-agent/declarations/main";
    import FormTemplate from "./FormTemplate.svelte";

    export let townId: bigint;

    let generateProposal = (): TownProposalContent | string => {
        return {
            increaseSize: {},
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <div class="p-2">Increase town size by 1</div>
</FormTemplate>
