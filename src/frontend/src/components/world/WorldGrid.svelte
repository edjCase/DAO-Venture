<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import HexGrid from "../common/HexGrid.svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import { HexTileKind } from "../common/HexTile.svelte";
    import Location from "./Location.svelte";
    import LocationInfo from "./LocationInfo.svelte";

    $: world = $worldStore;

    $: gridData = world?.locations.map((location) => {
        let kind: HexTileKind;
        if ("unexplored" in location.kind) {
            kind = { unexplored: null };
        } else if ("scenario" in location.kind) {
            kind = { explored: { icon: "🏰" } };
        } else {
            throw (
                "NOT IMPLEMENTED LOCATION KIND: " + toJsonString(location.kind)
            );
        }
        return {
            kind: kind,
            coordinate: {
                q: Number(location.coordinate.q),
                r: Number(location.coordinate.r),
            },
        };
    });
</script>

{#if gridData !== undefined && world !== undefined}
    <HexGrid {gridData} let:id>
        <Location locationId={id} />
        <div slot="tileInfo" let:selectedTile>
            {#if selectedTile !== undefined}
                <LocationInfo locationId={BigInt(selectedTile)} />
            {/if}
        </div>
    </HexGrid>
{/if}
