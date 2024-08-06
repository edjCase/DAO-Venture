<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import HexGrid from "../common/HexGrid.svelte";
    import PixelArtFlag from "../common/PixelArtFlag.svelte";
    import { userStore } from "../../stores/UserStore";
    import { toJsonString } from "../../utils/StringUtil";
    import TownFlag from "../town/TownFlag.svelte";
    import { Job } from "../../ic-agent/declarations/main";
    import ResourceHexTile from "./ResourceHexTile.svelte";
    import ResourceIcon from "../icons/ResourceIcon.svelte";

    $: towns = $townStore;
    $: world = $worldStore;

    $: gridData = world?.locations.map((location) => {
        return {
            faded: "unexplored" in location.kind,
            coordinate: {
                q: Number(location.coordinate.q),
                r: Number(location.coordinate.r),
            },
        };
    });

    $: user = $userStore;

    $: myTown = towns?.find((town) => town.id === user?.worldData?.townId);

    type TownJob = { townId: bigint; kind: Job };

    let locationJobMap: Map<bigint, TownJob[]> | undefined;
    $: if (world !== undefined && towns !== undefined) {
        locationJobMap = new Map<bigint, TownJob[]>();
        for (const location of world.locations) {
            let locationJobs = [];
            for (const town of towns) {
                for (const job of town.jobs) {
                    let locationId: bigint | undefined;
                    if ("explore" in job) {
                        locationId = job.explore.locationId;
                    } else {
                        console.error(
                            "NOT IMPLEMENTED JOB TYPE:",
                            toJsonString(job),
                        );
                    }
                    if (locationId === location.id) {
                        locationJobs.push({ townId: town.id, kind: job });
                    }
                }
            }
            locationJobMap.set(location.id, locationJobs);
        }
    }
</script>

{#if gridData !== undefined && world !== undefined}
    <HexGrid {gridData} let:id>
        {@const location = world.locations.find((l) => l.id == id)}
        {#if location !== undefined}
            {#if "town" in location.kind}
                {@const townOrUndefined = towns?.find(
                    (town) =>
                        "town" in location.kind &&
                        town.id === location.kind.town.townId,
                )}
                {#if townOrUndefined !== undefined}
                    <g transform="translate(-32, -24)">
                        <foreignObject x="0" y="0" width="64" height="48">
                            <PixelArtFlag
                                pixels={townOrUndefined.flagImage.pixels}
                                size="md"
                                border={true}
                            />
                        </foreignObject>
                    </g>
                {/if}
            {:else if "gold" in location.kind}
                <text
                    x="0"
                    y="0"
                    dominant-baseline="middle"
                    text-anchor="middle"
                    font-size="2em"
                >
                    <ResourceIcon kind={{ gold: null }} />
                </text>
            {:else if "wood" in location.kind}
                <text
                    x="0"
                    y="0"
                    dominant-baseline="middle"
                    text-anchor="middle"
                    font-size="2em"
                >
                    <ResourceIcon kind={{ wood: null }} />
                </text>
            {:else if "stone" in location.kind}
                <text
                    x="0"
                    y="0"
                    dominant-baseline="middle"
                    text-anchor="middle"
                    font-size="2em"
                >
                    <ResourceIcon kind={{ stone: null }} />
                </text>
            {:else if "food" in location.kind}
                <text
                    x="0"
                    y="0"
                    dominant-baseline="middle"
                    text-anchor="middle"
                    font-size="2em"
                >
                    <ResourceIcon kind={{ food: null }} />
                </text>
            {/if}
        {/if}
        <div slot="tileInfo" let:selectedTile>
            {#if selectedTile !== undefined}
                {@const location = world.locations.find(
                    (l) => l.id == BigInt(selectedTile),
                )}
                {#if location !== undefined}
                    <div class="bg-gray-800 rounded p-2">
                        <div class="text-center text-3xl">
                            Tile {selectedTile}

                            {#if "town" in location.kind}
                                {@const townOrUndefined = towns?.find(
                                    (town) =>
                                        "town" in location.kind &&
                                        town.id === location.kind.town.townId,
                                )}
                                {#if townOrUndefined !== undefined}
                                    <div>
                                        Town:
                                        {townOrUndefined.name}
                                        {#if townOrUndefined?.id === myTown?.id}
                                            (MY TOWN)
                                        {/if}
                                    </div>
                                {/if}
                            {:else if "resource" in location.kind}
                                <ResourceHexTile
                                    kind={location.kind.resource.kind}
                                    rarity={location.kind.resource.rarity}
                                />
                            {:else if "unexplored" in location.kind}
                                <div>Unexplored</div>
                                <div>
                                    Progress: {location.kind.unexplored
                                        .currentExploration}/{location.kind
                                        .unexplored.explorationNeeded}
                                </div>
                            {:else}
                                NOT IMPLEMENTED LOCATION KIND: {toJsonString(
                                    location.kind,
                                )}
                            {/if}
                            {#if locationJobMap !== undefined}
                                <div>JOBS:</div>
                                {@const locationJobs = locationJobMap.get(
                                    location.id,
                                )}
                                {#if locationJobs === undefined || locationJobs.length === 0}
                                    <div>-</div>
                                {:else}
                                    {#each locationJobs as job}
                                        {@const town = towns?.find(
                                            (town) => town.id === job.townId,
                                        )}
                                        <div class="flex justify-center gap-2">
                                            {#if town !== undefined}
                                                <TownFlag {town} size="xs" />
                                            {/if}
                                            {#if "explore" in job.kind}
                                                <div>Explore</div>
                                                <div>
                                                    Location: {job.kind.explore
                                                        .locationId}
                                                </div>
                                            {:else}
                                                NOT IMPLEMENTED JOB TYPE: {toJsonString(
                                                    job,
                                                )}
                                            {/if}
                                        </div>
                                    {/each}
                                {/if}
                            {/if}
                        </div>
                    </div>
                {/if}
            {/if}
        </div>
    </HexGrid>
{/if}
