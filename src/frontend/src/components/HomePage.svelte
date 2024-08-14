<script lang="ts">
    import WorldGrid from "./world/WorldGrid.svelte";
    import { worldStore } from "../stores/WorldStore";
    import LoadingButton from "./common/LoadingButton.svelte";
    import { mainAgentFactory } from "../ic-agent/Main";

    $: world = $worldStore;

    let nextTurn = async () => {
        let mainAgent = await mainAgentFactory();
        await mainAgent.nextTurn();
        worldStore.refetch();
    };
</script>

<div class="bg-gray-800 rounded p-2">
    {#if world !== undefined}
        <LoadingButton onClick={nextTurn}>Next Turn</LoadingButton>
        <WorldGrid />
    {/if}
</div>
