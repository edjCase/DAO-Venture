<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { toJsonString } from "../../utils/StringUtil";
    import ResourceLocationInfo from "./ResourceLocationInfo.svelte";

    export let locationId: bigint;

    $: world = $worldStore;

    $: location = world?.locations.find((l) => l.id == locationId);
</script>

{#if location !== undefined}
    <div class="bg-gray-800 rounded p-2">
        <div class="text-center text-3xl">
            Tile {locationId}

            {#if "town" in location.kind}
                <div></div>
            {:else if "resource" in location.kind}
                <ResourceLocationInfo
                    kind={location.kind.resource.kind}
                    rarity={location.kind.resource.rarity}
                />
            {:else if "unexplored" in location.kind}
                <div>Unexplored</div>
            {:else}
                NOT IMPLEMENTED LOCATION KIND: {toJsonString(location.kind)}
            {/if}
        </div>
    </div>
{/if}
