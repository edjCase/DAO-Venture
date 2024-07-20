<script lang="ts">
    import { ChangeTownColorContent__1 } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";
    import RgbColor from "../../../common/RgbColor.svelte";

    export let content: ChangeTownColorContent__1;
    $: towns = $townStore;

    let town = towns?.find((town) => town.id === content.townId);
</script>

<div>Town Id: {content.townId}</div>
<div>Current Name: {town?.name}</div>

<RgbColor value={content.color} disabled />
