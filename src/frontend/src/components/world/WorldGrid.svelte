<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import HexGrid from "../common/HexGrid.svelte";

    $: towns = $townStore;
    $: locations = $worldStore;

    $: gridData = locations?.map((location) => {
        let townName =
            towns?.find((town) => town.id === location.townId[0])?.name || "";
        return {
            coord: {
                q: Number(location.coordinate.q),
                r: Number(location.coordinate.r),
            },
            value: location.id.toString() + " " + townName,
        };
    });
</script>

{#if gridData !== undefined}
    <HexGrid {gridData} />
{/if}
