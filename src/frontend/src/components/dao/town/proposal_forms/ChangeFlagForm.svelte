<script lang="ts">
    import { Label } from "flowbite-svelte";
    import {
        FlagImage,
        TownProposalContent,
    } from "../../../../ic-agent/declarations/main";
    import FormTemplate from "./FormTemplate.svelte";
    import PixelArtCreator from "../../../common/PixelArtCreator.svelte";

    export let townId: bigint;

    let height = 24;
    let width = 32;
    let image: FlagImage = {
        pixels: Array(height)
            .fill(null)
            .map(() => Array(width).fill({ red: 255, green: 255, blue: 255 })),
    };

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
    <PixelArtCreator pixels={image.pixels} />
</FormTemplate>
