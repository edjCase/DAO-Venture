<script lang="ts">
    import { Job, TownProposalContent } from "../../ic-agent/declarations/main";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { proposalStore } from "../../stores/ProposalStore";
    import { townStore } from "../../stores/TownStore";
    import { userStore } from "../../stores/UserStore";
    import { worldStore } from "../../stores/WorldStore";
    import { toJsonString } from "../../utils/StringUtil";
    import LoadingButton from "../common/LoadingButton.svelte";
    import TownFlag from "../town/TownFlag.svelte";
    import ResourceLocationInfo from "./ResourceLocationInfo.svelte";

    export let locationId: bigint;

    $: towns = $townStore;

    $: world = $worldStore;

    $: location = world?.locations.find((l) => l.id == locationId);

    $: user = $userStore;

    $: myTown = towns?.find((town) => town.id === user?.worldData?.townId);

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

    let joinTown = async () => {
        if (!location || !("town" in location.kind)) {
            console.error("Town must be selected to join");
            return;
        }
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.joinWorld({
            townId: location.kind.town.townId,
        });
        if ("ok" in result) {
            console.log("Joined world", result);
            userStore.refetchCurrentUser();
            userStore.refetchStats();
            townStore.refetch();
            worldStore.refetch();
        } else {
            console.log("Error joining world", result);
        }
    };

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

{#if location !== undefined}
    <div class="bg-gray-800 rounded p-2">
        <div class="text-center text-3xl">
            Tile {locationId}

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
                        {:else if myTown === undefined}
                            <LoadingButton onClick={joinTown}>
                                Join Town
                            </LoadingButton>
                        {/if}
                    </div>
                {/if}
            {:else if "resource" in location.kind}
                <ResourceLocationInfo
                    kind={location.kind.resource.kind}
                    rarity={location.kind.resource.rarity}
                />
                {#if location.kind.resource.claimedByTownIds.length > 0}
                    Claimed By: {location.kind.resource.claimedByTownIds
                        .map(
                            (id) =>
                                towns?.find((to) => to.id == id)?.name || id,
                        )
                        .join(", ")}
                {:else}
                    Unclaimed
                {/if}
                {#if myTown !== undefined && !location.kind.resource.claimedByTownIds.includes(myTown?.id)}
                    <!-- TODO only do 'adjacent' locations to territory-->
                    <LoadingButton onClick={claimLocation(location.id)}
                        >Propose Annexation to DAO</LoadingButton
                    >
                {/if}
            {:else if "unexplored" in location.kind}
                <div>Unexplored</div>
                <div>
                    Progress: {location.kind.unexplored
                        .currentExploration}/{location.kind.unexplored
                        .explorationNeeded}
                </div>

                {#if myTown !== undefined && !myTown.jobs.some((j) => "explore" in j && j.explore.locationId === location.id)}
                    <LoadingButton onClick={exploreLocation(location.id)}
                        >Propose Exploration to DAO</LoadingButton
                    >
                {/if}
            {:else}
                NOT IMPLEMENTED LOCATION KIND: {toJsonString(location.kind)}
            {/if}
            {#if locationJobMap !== undefined}
                <div>JOBS:</div>
                {@const locationJobs = locationJobMap.get(location.id)}
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
                                    Location: {job.kind.explore.locationId}
                                </div>
                            {:else}
                                NOT IMPLEMENTED JOB TYPE: {toJsonString(job)}
                            {/if}
                        </div>
                    {/each}
                {/if}
            {/if}
        </div>
    </div>
{/if}
