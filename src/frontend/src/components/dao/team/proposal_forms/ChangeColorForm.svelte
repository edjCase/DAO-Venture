<script lang="ts">
    import RgbColor from "../../../common/RgbColor.svelte";
    import FormTemplate from "./FormTemplate.svelte";
    import { ProposalContent } from "../../../../ic-agent/declarations/main";
    import { Label } from "flowbite-svelte";

    export let townId: bigint;
    let rgb: [number, number, number] = [0, 0, 0];

    let generateProposal = (): ProposalContent | string => {
        return {
            changeColor: {
                color: rgb,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <div class="p-2">Updates the color of the town.</div>
    <div class="p-2">Requires a league approval vote.</div>
    <Label>Color</Label>
    <RgbColor bind:value={rgb} />
</FormTemplate>
