<script lang="ts">
    import { LeagueData, Team } from "../../ic-agent/declarations/main";
    import { leagueStore } from "../../stores/LeagueStore";
    import { teamStore } from "../../stores/TeamStore";
    import EntropyGauge from "./EntropyGauge.svelte";

    let teams: Team[] = [];
    let leagueData: LeagueData | undefined;

    teamStore.subscribe((t) => {
        if (!t) {
            return;
        }
        teams = t;
        teams.sort((a, b) => Number(b.entropy) - Number(a.entropy));
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
