<script lang="ts">
    import RgbColor from "../../../common/RgbColor.svelte";
    import FormTemplate from "./FormTemplate.svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/teams";

    export let teamId: bigint;
    let rgb: [number, number, number] = [0, 0, 0];

    let generateProposal = (): ProposalContent | string => {
        return {
            changeColor: {
                color: rgb,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {teamId}>
    <RgbColor bind:value={rgb} />
</FormTemplate>
