<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import Scenario from "../scenario/Scenario.svelte";

    export let locationId: bigint;

    $: world = $worldStore;

    $: location = world?.locations.find((l) => l.id == locationId);
</script>

{#if location !== undefined}
    <div class="bg-gray-800 rounded p-2">
        <div class="text-center text-3xl">
            Tile {locationId}
            <Scenario scenarioId={location.scenarioId} />
        </div>
    </div>
{/if}
