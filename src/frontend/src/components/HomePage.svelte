<script lang="ts">
    import { townStore } from "../stores/TownStore";
    import { userStore } from "../stores/UserStore";
    import { mainAgentFactory } from "../ic-agent/Main";
    import LoadingButton from "./common/LoadingButton.svelte";
    import WorldGrid from "./world/WorldGrid.svelte";

    $: user = $userStore;

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
    {#if user?.residency[0] === undefined}
        <div class="text-center text-3xl">
            <LoadingButton onClick={joinWorld}>Join World</LoadingButton>
        </div>
    {/if}
    <WorldGrid />
</div>
