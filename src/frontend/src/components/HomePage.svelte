<script lang="ts">
    import { townStore } from "../stores/TownStore";
    import { userStore } from "../stores/UserStore";
    import { mainAgentFactory } from "../ic-agent/Main";
    import LoadingButton from "./common/LoadingButton.svelte";
    import WorldGrid from "./world/WorldGrid.svelte";
    import Countdown from "./common/Countdown.svelte";
    import { worldStore } from "../stores/WorldStore";
    import { nanosecondsToDate } from "../utils/DateUtils";

    $: user = $userStore;
    $: towns = $townStore;

    $: myTown = towns?.find((town) => town.id === user?.townId);
    $: world = $worldStore;

    let joinWorld = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.joinWorld();
        if ("ok" in result) {
            console.log("Joined world", result);
            userStore.refetchCurrentUser();
            userStore.refetchStats();
            townStore.refetch();
        } else {
            console.log("Error joining world", result);
        }
    };
</script>

<div class="bg-gray-800 rounded p-2">
    <div class="flex jusity-between">
        <div class="flex-1">
            {#if world !== undefined}
                <div class="text-center text-3xl mb-5">
                    World Age: {world.age}
                </div>
                <div class="text-center text-xl flex flex-col items-center">
                    Next day: <Countdown
                        date={nanosecondsToDate(world.nextDayStartTime)}
                    />
                </div>
            {/if}
        </div>
        <div class="flex-1">
            {#if myTown !== undefined}
                <div class="text-center text-3xl">{myTown.name}</div>
                <div class="text-center text-xl">
                    Population: {myTown.population}
                </div>
                <div class="text-center text-xl">
                    Size: {myTown.size}
                </div>
                <div class="text-center text-xl">
                    Jobs: {myTown.jobs.length}
                </div>
            {:else}
                <div class="text-center text-3xl">
                    <LoadingButton onClick={joinWorld}>Join World</LoadingButton
                    >
                </div>
            {/if}
        </div>
    </div>
    <WorldGrid />
</div>
