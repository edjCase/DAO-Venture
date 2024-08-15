<script lang="ts">
    import WorldGrid from "./world/WorldGrid.svelte";
    import { gameStateStore } from "../stores/GameStateStore";
    import LoadingButton from "./common/LoadingButton.svelte";
    import { mainAgentFactory } from "../ic-agent/Main";
    import { userStore } from "../stores/UserStore";
    import { scenarioStore } from "../stores/ScenarioStore";

    $: gameState = $gameStateStore;
    $: user = $userStore;

    let nextTurn = async () => {
        let mainAgent = await mainAgentFactory();
        await mainAgent.nextTurn();
        gameStateStore.refetch();
        scenarioStore.refetch();
    };
    let start = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.startGame();
        if ("ok" in result) {
            gameStateStore.refetch();
        } else {
            console.error("Failed to start game", result);
        }
    };
    let join = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.join();
        if ("ok" in result) {
            userStore.refetchCurrentUser();
        } else {
            console.error("Failed to join game", result);
        }
    };
</script>

<div class="bg-gray-800 rounded p-2">
    {#if user?.worldData === undefined}
        <LoadingButton onClick={join}>Join</LoadingButton>
    {/if}
    {#if gameState !== undefined}
        <LoadingButton onClick={nextTurn}>Next Turn</LoadingButton>
        <WorldGrid />
    {:else}
        <LoadingButton onClick={start}>Start</LoadingButton>
    {/if}
</div>
