<script lang="ts">
    import WorldGrid from "./world/WorldGrid.svelte";
    import { worldStore } from "../stores/WorldStore";

    $: world = $worldStore;
</script>

<div class="bg-gray-800 rounded p-2">
    {#if world !== undefined}
        <WorldGrid />
    {/if}
</div>
