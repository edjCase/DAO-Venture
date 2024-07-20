<script lang="ts">
    import SeasonHome from "../components/season/SeasonHome.svelte";
    import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
    import EntropyHome from "./entropy/EntropyHome.svelte";
    import TopPredictorsHome from "./user/TopPredictorsHome.svelte";
    import { townStore } from "../stores/TownStore";
    import { userStore } from "../stores/UserStore";
    import { Button } from "flowbite-svelte";
    import { mainAgentFactory } from "../ic-agent/Main";

    $: towns = $townStore;

    let userCount: bigint | undefined;
    userStore.subscribeStats((stats) => {
        if (stats) {
            userCount = stats.userCount;
        }
    });

    $: user = $userStore;

    let joinTown = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.joinWorld();
        if ("ok" in result) {
            console.log("Joined world", result);
            userStore.refetchCurrentUser();
            userStore.refetchStats();
        } else {
            console.log("Error joining world", result);
        }
    };
</script>

<div class="bg-gray-800 rounded p-2">
    {#if towns && userCount !== undefined}
        {#if towns.length <= 0}
            <div class="p-4 text-center">
                <div class="text-3xl">World is in disarray</div>
                <div>
                    Waiting for the Benevolent Dictator (For Now) to start the
                    world
                </div>
            </div>
        {:else}
            {#if user !== undefined && user?.membership[0] === undefined}
                <div
                    class="flex flex-col items-center justify-center gap-2 mb-4"
                >
                    <div class="text-3xl text-center">
                        Want to join the world?
                    </div>
                    <Button on:click={joinTown}>Click Here</Button>
                </div>
            {/if}
            <div class="flex flex-col gap-6">
                <div>
                    <SeasonHome />
                </div>
                <div class="flex justify-around flex-wrap gap-6">
                    <EntropyHome />
                    <TopPredictorsHome />
                </div>
                <div>
                    <ScenarioHome />
                </div>
            </div>
        {/if}
    {/if}
</div>
