<script lang="ts">
    import LoginButton from "../common/LoginButton.svelte";
    import { userStore } from "../../stores/UserStore";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { worldStore } from "../../stores/WorldStore";

    $: user = $userStore;
    let intializeWorld = async () => {
        if (user === undefined) {
            console.error("User not logged in");
            return;
        }
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.intializeWorld();
        if ("ok" in result) {
            console.log("World initialized");
            userStore.refetchCurrentUser();
            userStore.refetchStats();
            worldStore.refetch();
        } else {
            console.error("Failed to initialize world", result.err);
        }
    };
</script>

<div class="text-center text-3xl">Initialize World</div>
<div class="px-20 mt-10">
    {#if user === undefined}
        <LoginButton />
    {:else}
        <div class="text-center mt-5">
            <LoadingButton onClick={intializeWorld} size="xl">
                Initialize
            </LoadingButton>
        </div>
    {/if}
</div>
