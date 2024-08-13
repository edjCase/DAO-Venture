<script lang="ts">
    import WorldGrid from "./world/WorldGrid.svelte";
    import { worldStore } from "../stores/WorldStore";
    import InitializeWorld from "./world/InitializeWorld.svelte";

    $: world = $worldStore;
</script>

<div class="bg-gray-800 rounded p-2">
    {#if world !== undefined}
        <div class="flex jusity-between">
            <div class="flex-1">
                <div class="text-center text-3xl mb-5">
                    Turn: {world.turn}
                </div>
            </div>
        </div>
        <WorldGrid />
    {:else}
        <InitializeWorld />
    {/if}
</div>
