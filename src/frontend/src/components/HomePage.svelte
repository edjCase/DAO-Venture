<script lang="ts">
    import SeasonHome from "../components/season/SeasonHome.svelte";
    import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
    import EntropyHome from "./entropy/EntropyHome.svelte";
    import PointsLeaderboard from "./user/PointsLeaderboard.svelte";
    import { teamStore } from "../stores/TeamStore";
    import { userStore } from "../stores/UserStore";
    import LoginButton from "./common/LoginButton.svelte";
    import { mainAgentFactory } from "../ic-agent/Main";
    import LoadingButton from "./common/LoadingButton.svelte";

    $: teams = $teamStore;

    let userCount: bigint | undefined;
    userStore.subscribeStats((stats) => {
        if (stats) {
            userCount = stats.userCount;
        }
    });

    $: user = $userStore;

    let join = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.joinLeague();
        if ("ok" in result) {
            console.log("Joined league", result);
            userStore.refetchCurrentUser();
            userStore.refetchStats();
        } else {
            console.log("Error joining league", result);
        }
    };
</script>

<div class="bg-gray-800 rounded">
    {#if teams && userCount !== undefined}
        {#if teams.length <= 0}
            <div class="p-4 text-center">
                <div class="text-3xl">League is in disarray</div>
                <div class="text-xl">
                    Teams must be formed and come together
                </div>
                <div>
                    {userCount} individual(s) have come together to form a league
                </div>
                {#if !user}
                    <LoginButton />
                {:else if user.membership[0]}
                    <div class="text-3xl">INCLUDING YOU</div>
                {:else}
                    <div class="flex items-center justify-center">
                        <LoadingButton onClick={join}>
                            Join the League
                        </LoadingButton>
                    </div>
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
