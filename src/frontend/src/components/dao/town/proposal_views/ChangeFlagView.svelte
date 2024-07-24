<script lang="ts">
    import { ChangeTownFlagContent } from "../../../../ic-agent/declarations/main";
    import PixelArtFlag from "../../../common/PixelArtFlag.svelte";

    export let content: ChangeTownFlagContent;
</script>

<div class="flex justify-center">
    <PixelArtFlag pixels={content.image.pixels} size="lg" />
</div>
