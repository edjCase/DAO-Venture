<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import HexGrid from "../common/HexGrid.svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import { HexTileKind } from "../common/HexTile.svelte";
    import Location from "./Location.svelte";
    import LocationInfo from "./LocationInfo.svelte";

    $: towns = $townStore;
    $: world = $worldStore;

    $: gridData = world?.locations.map((location) => {
        let kind: HexTileKind;
        if ("unexplored" in location.kind) {
            kind = { unexplored: null };
        } else if ("town" in location.kind) {
            let townId = location.kind.town.townId;
            let claimedByTowns = towns?.filter((t) => t.id == townId) || [];
            kind = { explored: { towns: claimedByTowns } };
        } else if ("resource" in location.kind) {
            let townIds = location.kind.resource.claimedByTownIds;
            let claimedByTowns =
                towns?.filter((t) => townIds.includes(t.id)) || [];
            kind = {
                explored: {
                    towns: claimedByTowns,
                },
            };
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
