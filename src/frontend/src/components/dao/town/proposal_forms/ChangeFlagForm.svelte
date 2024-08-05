<script lang="ts">
    import { Label } from "flowbite-svelte";
    import {
        FlagImage,
        TownProposalContent,
    } from "../../../../ic-agent/declarations/main";
    import FormTemplate from "./FormTemplate.svelte";
    import TownFlagCreator from "../../../town/TownFlagCreator.svelte";

    export let townId: bigint;

    let image: FlagImage | undefined;

    let generateProposal = (): TownProposalContent | string => {
        if (image === undefined) {
            return "No logo url provided";
        }
        return {
            changeFlag: {
                image: image,
            },
        };
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <div class="p-2">Updates the logo of the town.</div>
    <div class="p-2">Requires a world approval vote.</div>
    <Label>Flag</Label>
    <TownFlagCreator bind:value={image} />
</FormTemplate>
