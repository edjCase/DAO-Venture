<script lang="ts">
    import { townStore } from "../stores/TownStore";
    import { userStore } from "../stores/UserStore";
    import { mainAgentFactory } from "../ic-agent/Main";
    import LoadingButton from "./common/LoadingButton.svelte";
    import WorldGrid from "./world/WorldGrid.svelte";
    import Countdown from "./common/Countdown.svelte";
    import { worldStore } from "../stores/WorldStore";
    import { nanosecondsToDate } from "../utils/DateUtils";
    import ResourceIcon from "./icons/ResourceIcon.svelte";

    $: user = $userStore;
    $: towns = $townStore;

    $: myTown = towns?.find((town) => town.id === user?.worldData?.townId);
    $: world = $worldStore;

    let joinWorld = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.joinWorld();
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

    let townIncome: {
        gold: number;
        wood: number;
        stone: number;
        food: number;
    } = {
        gold: 0,
        wood: 0,
        stone: 0,
        food: 0,
    };
    $: {
        if (world !== undefined && myTown !== undefined) {
            townIncome = world?.locations.reduce(
                (acc, location) => {
                    if (
                        "resource" in location.kind &&
                        location.kind.resource.claimedByTownIds.includes(
                            myTown.id,
                        )
                    ) {
                        let amount = 10; // TODO: calculate amount based on rarity
                        if ("uncommon" in location.kind.resource.rarity) {
                            amount = 12;
                        } else if ("rare" in location.kind.resource.rarity) {
                            amount = 15;
                        }

                        if ("gold" in location.kind.resource.kind) {
                            acc.gold += amount;
                        } else if ("wood" in location.kind.resource.kind) {
                            acc.wood += amount;
                        } else if ("stone" in location.kind.resource.kind) {
                            acc.stone += amount;
                        } else if ("food" in location.kind.resource.kind) {
                            acc.food += amount;
                        }
                    }
                    return acc;
                },
                {
                    gold: 0,
                    wood: 0,
                    stone: 0,
                    food: 0,
                },
            );
        }
    }
</script>

<div class="bg-gray-800 rounded p-2">
    <div class="flex jusity-between">
        <div class="flex-1">
            {#if world !== undefined}
                <div class="text-center text-3xl mb-5">
                    World Age: {world.daysElapsed}
                </div>
                <div class="text-center text-xl flex flex-col items-center">
                    Next day: <Countdown
                        date={nanosecondsToDate(world.nextDayStartTime)}
                    />
                </div>
            {/if}
        </div>
        <div class="flex-1 text-center text-xl">
            {#if myTown !== undefined}
                <div class="text-3xl">{myTown.name}</div>
                <div class="">
                    Population: {myTown.population}
                </div>
                <div class="">
                    Size: {myTown.size}
                </div>
                <div class="">
                    Jobs: {myTown.jobs.length}
                </div>
                <div>
                    <div>
                        {townIncome.gold}
                        <ResourceIcon kind={{ gold: null }} />/day
                    </div>
                    <div>
                        {townIncome.wood}
                        <ResourceIcon kind={{ wood: null }} />/day
                    </div>
                    <div>
                        {townIncome.stone}
                        <ResourceIcon kind={{ stone: null }} />/day
                    </div>
                    <div>
                        {townIncome.food}
                        <ResourceIcon kind={{ food: null }} />/day
                    </div>
                </div>
            {:else}
                <div class="text-3xl">
                    <LoadingButton onClick={joinWorld}>Join World</LoadingButton
                    >
                </div>
            {/if}
        </div>
    </div>
    <WorldGrid />
</div>
