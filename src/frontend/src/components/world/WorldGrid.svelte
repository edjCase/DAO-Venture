<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import HexGrid, { HexTileData } from "../common/HexGrid.svelte";
    import Location from "./Location.svelte";
    import LocationInfo from "./LocationInfo.svelte";
    import { World } from "../../ic-agent/declarations/main";

    let selectedTileId: number | undefined;
    let world: World | undefined;
    let gridData: HexTileData[] | undefined;

    worldStore.subscribe((newWorld) => {
        if (newWorld === undefined) {
            return;
        }
        if (world === undefined) {
            selectedTileId = Number(newWorld.characterLocationId);
        }
        world = newWorld;
        gridData = world.locations.map((location) => {
            return {
                id: Number(location.id),
                kind: { explored: { icon: "" } },
                coordinate: {
                    q: Number(location.coordinate.q),
                    r: Number(location.coordinate.r),
                },
            };
        });
    });
</script>

{#if gridData !== undefined && world !== undefined}
    <HexGrid {gridData} bind:selectedTileId let:id>
        <Location locationId={BigInt(id)} />
        <div slot="tileInfo" let:selectedTile>
            {#if selectedTile !== undefined}
                <LocationInfo locationId={BigInt(selectedTile)} />
            {/if}
        </div>
    </HexGrid>
{/if}
