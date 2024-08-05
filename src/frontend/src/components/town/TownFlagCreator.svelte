<script lang="ts">
    import { FlagImage } from "../../ic-agent/declarations/main";
    import PixelArtCreator from "../common/PixelArtCreator.svelte";

    export let value: FlagImage | undefined;

    let height = 12;
    let width = 16;
    let flag = value || {
        pixels: Array(height)
            .fill(null)
            .map(() => Array(width).fill({ red: 255, green: 255, blue: 255 })),
    };
    $: value = flag;
</script>

<PixelArtCreator bind:pixels={flag.pixels} />
