<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { toJsonString } from "../../utils/StringUtil";

    export let locationId: bigint;

    $: world = $worldStore;

    $: location = world?.locations.find((l) => l.id == locationId);
</script>

{#if location !== undefined}
    <div class="bg-gray-800 rounded p-2">
        <div class="text-center text-3xl">
            Tile {locationId}

            {#if "scenario" in location.kind}
                <div>Scenario: {location.kind.scenario}</div>
            {:else if "unexplored" in location.kind}
                <div>Unexplored</div>
            {:else}
                NOT IMPLEMENTED LOCATION KIND: {toJsonString(location.kind)}
            {/if}
        </div>
    </div>
{/if}
