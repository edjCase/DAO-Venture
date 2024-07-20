<script lang="ts">
    import { WorldData, Town } from "../../ic-agent/declarations/main";
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import EntropyGauge from "./EntropyGauge.svelte";

    let towns: Town[] = [];
    let worldData: WorldData | undefined;

    townStore.subscribe((t) => {
        if (!t) {
            return;
        }
        towns = t;
        towns.sort((a, b) => Number(b.entropy) - Number(a.entropy));
    });
    worldStore.subscribeData((data) => {
        worldData = data;
    });
</script>

<div>
    <div class="text-3xl text-center">Entropy</div>
    <div class="border border-2 rounded border-gray-700">
        {#if !worldData}
            <div></div>
        {:else}
            <EntropyGauge {worldData} />
        {/if}
    </div>
</div>
