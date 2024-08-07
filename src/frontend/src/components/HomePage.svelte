<script lang="ts">
    import { townStore } from "../stores/TownStore";
    import { userStore } from "../stores/UserStore";
    import WorldGrid from "./world/WorldGrid.svelte";
    import Countdown from "./common/Countdown.svelte";
    import { worldStore } from "../stores/WorldStore";
    import { nanosecondsToDate } from "../utils/DateUtils";
    import ResourceIcon from "./icons/ResourceIcon.svelte";
    import { Button } from "flowbite-svelte";
    import { Link } from "svelte-routing";
    import { ArrowUpRightFromSquareOutline } from "flowbite-svelte-icons";
    import InitializeWorld from "./world/InitializeWorld.svelte";

    $: user = $userStore;
    $: towns = $townStore;

    $: myTown = towns?.find((town) => town.id === user?.worldData?.townId);
    $: world = $worldStore;

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
    {#if world !== undefined}
        <div class="flex jusity-between">
            <div class="flex-1">
                <div class="text-center text-3xl mb-5">
                    World Age: {world.daysElapsed}
                </div>
                <div class="text-center text-xl flex flex-col items-center">
                    Next day: <Countdown
                        date={nanosecondsToDate(world.nextDayStartTime)}
                    />
                </div>
            </div>
            {#if myTown !== undefined}
                <div class="flex-1 text-center text-xl">
                    <div class="text-3xl">{myTown.name}</div>
                    <div class="">
                        Size: {myTown.size}/{myTown.sizeLimit}
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
                </div>
            {:else}
                <div>
                    <Link to="/how-to-play">
                        <Button class="p-4 text-center text-3xl">
                            <span class="mr-2">How To Play</span>
                            <ArrowUpRightFromSquareOutline />
                        </Button>
                    </Link>
                    <div>Select town on grid to join</div>
                </div>
            {/if}
        </div>
        <WorldGrid />
    {:else}
        <InitializeWorld />
    {/if}
</div>
