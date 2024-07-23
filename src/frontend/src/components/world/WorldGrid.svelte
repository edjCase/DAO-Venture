<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import HexGrid from "../common/HexGrid.svelte";
    import PixelArtFlag from "../common/PixelArtFlag.svelte";

    $: towns = $townStore;
    $: locations = $worldStore;

    $: gridData = locations?.map((location) => {
        return {
            coordinate: {
                q: Number(location.coordinate.q),
                r: Number(location.coordinate.r),
            },
        };
    });
</script>

{#if gridData !== undefined && locations !== undefined}
    <HexGrid {gridData} let:id>
        {@const location = locations[id]}
        {@const townOrUndefined = towns?.find(
            (town) => town.id === location.townId[0],
        )}
        {#if townOrUndefined !== undefined}
            <g transform="translate(-16, -12)">
                <PixelArtFlag
                    pixels={townOrUndefined.flagImage.pixels}
                    size="xxs"
                    border={true}
                />
            </g>
        {/if}
        <div slot="tileInfo" let:selectedTile>
            {#if selectedTile !== undefined}
                {@const location = locations[selectedTile]}
                {@const townOrUndefined = towns?.find(
                    (town) => town.id === location.townId[0],
                )}
                <div class="bg-gray-800 rounded p-2">
                    <div class="text-center text-3xl">
                        {#if townOrUndefined === undefined}
                            Area {selectedTile}
                        {:else}
                            {townOrUndefined.name}
                        {/if}
                        {#each location.resources as resource}
                            <div class="text-center text-3xl">
                                {#if "wood" in resource}
                                    {resource.wood} Wood
                                {:else if "stone" in resource}
                                    {resource.stone} Stone
                                {:else if "food" in resource}
                                    {resource.food} Food
                                {/if}
                            </div>
                        {/each}
                    </div>
                </div>
            {/if}
        </div>
    </HexGrid>
{/if}
