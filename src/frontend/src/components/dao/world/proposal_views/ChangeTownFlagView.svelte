<script lang="ts">
    import { ChangeTownFlagContent } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";
    import PixelArtFlag from "../../../common/PixelArtFlag.svelte";

    export let content: ChangeTownFlagContent;
    $: towns = $townStore;

    $: town = towns?.find((town) => town.id === content.townId);
</script>

<div>Town: {town?.name} ({content.townId})</div>

<div class="flex justify-center">
    <PixelArtFlag pixels={content.flagImage.pixels} size="lg" />
</div>
