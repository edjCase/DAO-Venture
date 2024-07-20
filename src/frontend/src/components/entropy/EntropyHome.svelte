<script lang="ts">
    import { LeagueData, Town } from "../../ic-agent/declarations/main";
    import { leagueStore } from "../../stores/LeagueStore";
    import { townStore } from "../../stores/TownStore";
    import EntropyGauge from "./EntropyGauge.svelte";

    let towns: Town[] = [];
    let leagueData: LeagueData | undefined;

    townStore.subscribe((t) => {
        if (!t) {
            return;
        }
        towns = t;
        towns.sort((a, b) => Number(b.entropy) - Number(a.entropy));
    });
    leagueStore.subscribeData((data) => {
        leagueData = data;
    });
</script>

<div>
    <div class="text-3xl text-center">Entropy</div>
    <div class="border border-2 rounded border-gray-700">
        {#if !leagueData}
            <div></div>
        {:else}
            <EntropyGauge {leagueData} />
        {/if}
    </div>
</div>
