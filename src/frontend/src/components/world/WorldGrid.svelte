<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import HexGrid from "../common/HexGrid.svelte";
    import PixelArtFlag from "../common/PixelArtFlag.svelte";
    import ResourceIcon from "../icons/ResourceIcon.svelte";
    import { userStore } from "../../stores/UserStore";
    import { toJsonString } from "../../utils/StringUtil";
    import TownFlag from "../town/TownFlag.svelte";
    import { Job } from "../../ic-agent/declarations/main";

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
                    if ("gatherResource" in job) {
                        locationId = job.gatherResource.locationId;
                    } else if ("processResource" in job) {
                        // Get town location
                        locationId = world.locations.find(
                            (location) =>
                                "standard" in location.kind &&
                                location.kind.standard.townId[0] === town.id,
                        )?.id;
                    } else if ("explore" in job) {
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
        {@const townOrUndefined = towns?.find(
            (town) =>
                location &&
                "standard" in location.kind &&
                town.id === location.kind.standard.townId[0],
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
                {@const location = world.locations.find(
                    (l) => l.id == BigInt(selectedTile),
                )}
                {#if location !== undefined}
                    {@const townOrUndefined = towns?.find(
                        (town) =>
                            "standard" in location.kind &&
                            town.id === location.kind.standard.townId[0],
                    )}
                    <div class="bg-gray-800 rounded p-2">
                        <div class="text-center text-3xl">
                            Tile {selectedTile}
                            <div>
                                Town:
                                {#if townOrUndefined !== undefined}
                                    {townOrUndefined.name}
                                    {#if townOrUndefined?.id === myTown?.id}
                                        (MY TOWN)
                                    {/if}
                                {:else}
                                    -
                                {/if}
                            </div>

                            {#if "standard" in location.kind}
                                {@const reasources = [
                                    {
                                        kind: { gold: null },
                                        type: "difficulty",
                                        value: location.kind.standard.resources
                                            .gold.difficulty,
                                    },
                                    {
                                        kind: { wood: null },
                                        type: "amount",
                                        value: location.kind.standard.resources
                                            .wood.amount,
                                    },
                                    {
                                        kind: { stone: null },
                                        type: "difficulty",
                                        value: location.kind.standard.resources
                                            .stone.difficulty,
                                    },
                                    {
                                        kind: { food: null },
                                        type: "amount",
                                        value: location.kind.standard.resources
                                            .food.amount,
                                    },
                                ]}
                                <div
                                    class="flex flex-wrap justify-around gap-2"
                                >
                                    {#each reasources as resource}
                                        <div
                                            class="flex items-center justify-center border border-gray-700 rounded p-2 min-w-24"
                                        >
                                            <div class="text-md">
                                                <ResourceIcon
                                                    kind={resource.kind}
                                                />
                                            </div>
                                            <span
                                                class="flex items-center gap-1"
                                            >
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
                                            {#if "gatherResource" in job.kind}
                                                <div>
                                                    Gather
                                                    <ResourceIcon
                                                        kind={job.kind
                                                            .gatherResource
                                                            .resource}
                                                    />
                                                </div>
                                                <div>
                                                    {job.kind.gatherResource
                                                        .workerQuota}
                                                </div>
                                            {:else if "processResource" in job.kind}
                                                <div>
                                                    Process
                                                    <ResourceIcon
                                                        kind={job.kind
                                                            .processResource
                                                            .resource}
                                                    />
                                                </div>
                                                <div>
                                                    {job.kind.processResource
                                                        .workerQuota}
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
