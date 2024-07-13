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

    $: user = $userStore;
</script>

<div class="bg-gray-800 rounded">
    {#if teams && userCount !== undefined}
        {#if teams.length <= 0}
            <div class="p-4">
                <div class="text-center text-3xl">League is in disarray</div>
                <div class="text-center text-xl">
                    Teams must be formed and come together
                </div>
                <div>
                    {userCount} individuals have come together to form a league
                </div>
                {#if user}
                    LoggedIn
                    {#if user.team[0]}
                        On Team
                    {/if}
                {:else}
                    Not Logged In
                {/if}
            </div>
        {:else}
            <SeasonHome />
            <EntropyHome />
            <ScenarioHome />
            <PointsLeaderboard />
        {/if}
    {/if}
</div>
