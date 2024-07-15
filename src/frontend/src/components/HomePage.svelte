<script lang="ts">
    import SeasonHome from "../components/season/SeasonHome.svelte";
    import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
    import EntropyHome from "./entropy/EntropyHome.svelte";
    import PointsLeaderboard from "./user/PointsLeaderboard.svelte";
    import { teamStore } from "../stores/TeamStore";
    import { userStore } from "../stores/UserStore";

    $: teams = $teamStore;

    let userCount: bigint | undefined;
    userStore.subscribeStats((stats) => {
        if (stats) {
            userCount = stats.userCount;
        }
    });
</script>

<div class="bg-gray-800 rounded">
    {#if teams && userCount !== undefined}
        {#if teams.length <= 0}
            <div class="p-4 text-center">
                <div class="text-3xl">League is in disarray</div>
                <div>
                    Waiting for the Benevolent Dictator (For Now) to start the
                    league
                </div>
            </div>
        {:else}
            <SeasonHome />
            <EntropyHome />
            <ScenarioHome />
            <PointsLeaderboard />
        {/if}
    {/if}
</div>
