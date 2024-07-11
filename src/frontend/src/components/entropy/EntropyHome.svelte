<script lang="ts">
    import { LeagueData, Team } from "../../ic-agent/declarations/main";
    import { leagueStore } from "../../stores/LeagueStore";
    import { teamStore } from "../../stores/TeamStore";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
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

<SectionWithOverview title="Entropy">
    <ul slot="details" class="list-disc list-inside text-sm space-y-1">
        <li>Entropy is a measure of chaos in the league</li>
        <li>
            If the entropy gets too high, the league will collapse into chaos
        </li>
        <li>
            Each team has their own entropy metric. When the team is
            collaborative the entropy goes down, when selfish it goes up
        </li>
    </ul>
    <div class="border-2 rounded border-gray-700 p-4">
        <div class="mx-auto">
            {#if !leagueData}
                <div></div>
            {:else}
                <EntropyGauge {leagueData} />
            {/if}
        </div>
    </div>
</SectionWithOverview>
