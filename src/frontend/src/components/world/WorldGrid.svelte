<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import HexGrid from "../common/HexGrid.svelte";
    import { userStore } from "../../stores/UserStore";
    import { toJsonString } from "../../utils/StringUtil";
    import TownFlag from "../town/TownFlag.svelte";
    import { Job, TownProposalContent } from "../../ic-agent/declarations/main";
    import ResourceLocation from "./ResourceLocationInfo.svelte";
    import { HexTileKind } from "../common/HexTile.svelte";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { proposalStore } from "../../stores/ProposalStore";
    import Location from "./Location.svelte";

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

    let createTownProposal = async (content: TownProposalContent) => {
        if (myTown !== undefined) {
            let mainAgent = await mainAgentFactory();
            let result = await mainAgent.createTownProposal(myTown.id, content);
            if ("ok" in result) {
                console.log("Proposal Created", result.ok);
                proposalStore.refetchTownProposals(myTown.id);
            } else {
                console.log("Error creating proposal", result.err);
            }
        }
    };

    let claimLocation = (locationId: bigint) => async () => {
        await createTownProposal({
            claimLocation: {
                locationId,
                leaveLocationId: [], // TODO
            },
        });
    };

    let exploreLocation = (locationId: bigint) => async () => {
        await createTownProposal({
            addJob: {
                job: {
                    explore: {
                        locationId,
                    },
                },
            },
        });
    };
</script>

{#if gridData !== undefined && world !== undefined}
    <HexGrid {gridData} let:id>
        <Location locationId={id} />
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
                                <ResourceLocation
                                    kind={location.kind.resource.kind}
                                    rarity={location.kind.resource.rarity}
                                />
                                {#if location.kind.resource.claimedByTownIds.length > 0}
                                    Claimed By: {location.kind.resource.claimedByTownIds.join(
                                        ", ",
                                    )}
                                {:else}
                                    Unclaimed
                                {/if}
                                {#if myTown !== undefined && !location.kind.resource.claimedByTownIds.includes(myTown?.id)}
                                    <LoadingButton
                                        onClick={claimLocation(location.id)}
                                        >Propose Annexation to DAO</LoadingButton
                                    >
                                {/if}
                            {:else if "unexplored" in location.kind}
                                <div>Unexplored</div>
                                <div>
                                    Progress: {location.kind.unexplored
                                        .currentExploration}/{location.kind
                                        .unexplored.explorationNeeded}
                                </div>

                                {#if myTown !== undefined && !myTown.jobs.some((j) => "explore" in j && j.explore.locationId === location.id)}
                                    <LoadingButton
                                        onClick={exploreLocation(location.id)}
                                        >Propose Exploration to DAO</LoadingButton
                                    >
                                {/if}
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
