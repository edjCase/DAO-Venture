<script lang="ts">
    import { TownProposalContent } from "../../../../ic-agent/declarations/main";
    import ResourceIcon from "../../../icons/ResourceIcon.svelte";
    import FormTemplate from "./FormTemplate.svelte";

    export let townId: bigint;

    let generateProposal = (): TownProposalContent | string => {
        return {
            increaseSize: {},
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <div class="p-2">
        Increase town size by 1. Costs {"{"}town size{"}"} * 1000
        <ResourceIcon kind={{ wood: null }} />
        and
        <ResourceIcon kind={{ stone: null }} />
    </div>
</FormTemplate>
