<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import HexGrid from "../common/HexGrid.svelte";
    import PixelArtFlag from "../common/PixelArtFlag.svelte";
    import ResourceIcon from "../icons/ResourceIcon.svelte";

    $: towns = $townStore;
    $: world = $worldStore;

    $: gridData = world?.locations.map((location) => {
        return {
            coordinate: {
                q: Number(location.coordinate.q),
                r: Number(location.coordinate.r),
            },
        };
    });
</script>

{#if gridData !== undefined && world !== undefined}
    <HexGrid {gridData} let:id>
        {@const location = world.locations[id]}
        {@const townOrUndefined = towns?.find(
            (town) => town.id === location.townId[0],
        )}
        {#if townOrUndefined !== undefined}
            <g transform="translate(-16, -42)">
                <foreignObject x="0" y="0" width="100%" height="100%">
                    <PixelArtFlag
                        pixels={townOrUndefined.flagImage.pixels}
                        size="xs"
                        border={true}
                    />
                </foreignObject>
            </g>
        {/if}
        <text
            x="0"
            y="0"
            text-anchor="middle"
            dominant-baseline="middle"
            class="text-xl font-bold fill-gray-500"
        >
            {id}
        </text>
        <div slot="tileInfo" let:selectedTile>
            {#if selectedTile !== undefined}
                {@const location = world.locations[selectedTile]}
                {@const townOrUndefined = towns?.find(
                    (town) => town.id === location.townId[0],
                )}
                {@const reasources = [
                    {
                        kind: { gold: null },
                        type: "difficulty",
                        value: location.resources.gold.difficulty,
                    },
                    {
                        kind: { wood: null },
                        type: "amount",
                        value: location.resources.wood.amount,
                    },
                    {
                        kind: { stone: null },
                        type: "difficulty",
                        value: location.resources.stone.difficulty,
                    },
                    {
                        kind: { food: null },
                        type: "amount",
                        value: location.resources.food.amount,
                    },
                ]}
                <div class="bg-gray-800 rounded p-2">
                    <div class="text-center text-3xl">
                        Tile {selectedTile}
                        <div>
                            Town:
                            {#if townOrUndefined !== undefined}
                                {townOrUndefined.name}
                            {:else}
                                -
                            {/if}
                        </div>
                        <div class="flex flex-wrap justify-around gap-2">
                            {#each reasources as resource}
                                <div
                                    class="flex items-center justify-center border border-gray-700 rounded p-2 min-w-24"
                                >
                                    <div class="text-md">
                                        <ResourceIcon kind={resource.kind} />
                                    </div>
                                    <span class="flex items-center gap-1">
                                        {resource.value}
                                        <span class="text-xs">
                                            {#if resource.type === "difficulty"}
                                                Diff
                                            {:else if resource.type === "amount"}
                                                Units
                                            {/if}
                                        </span>
                                    </span>
                                </div>
                            {/each}
                        </div>
                    </div>
                </div>
            {/if}
        </div>
    </HexGrid>
{/if}
