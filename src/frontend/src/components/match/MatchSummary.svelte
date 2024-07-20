<script lang="ts">
    import {
        CompletedMatch,
        CompletedMatchTown,
    } from "../../ic-agent/declarations/main";
    import { townStore } from "../../stores/TownStore";
    import CompletedMatchCard, { TownStats } from "./CompletedMatchCard.svelte";

    export let match: CompletedMatch;
    export let matchGroupId: number;
    export let matchId: number;
    $: towns = $townStore;
    $: town1 = towns?.find((t) => t.id == match.town1.id);
    $: town2 = towns?.find((t) => t.id == match.town2.id);

    function compileTownStats(town: CompletedMatchTown): TownStats {
        return {
            totalHits: town.playerStats.reduce(
                (sum, player) => sum + Number(player.battingStats.hits),
                0,
            ),
            totalRuns: town.playerStats.reduce(
                (sum, player) => sum + Number(player.battingStats.runs),
                0,
            ),
            totalHomeRuns: town.playerStats.reduce(
                (sum, player) => sum + Number(player.battingStats.homeRuns),
                0,
            ),
            totalStrikeouts: town.playerStats.reduce(
                (sum, player) => sum + Number(player.battingStats.strikeouts),
                0,
            ),
            totalPitches: town.playerStats.reduce(
                (sum, player) => sum + Number(player.pitchingStats.pitches),
                0,
            ),
            totalStrikes: town.playerStats.reduce(
                (sum, player) => sum + Number(player.pitchingStats.strikes),
                0,
            ),
        };
    }

    $: town1Stats = compileTownStats(match.town1);
    $: town2Stats = compileTownStats(match.town2);
</script>

{#if town1 && town2 && town1Stats && town2Stats}
    <div class="w-full flex justify-around">
        <CompletedMatchCard
            {matchGroupId}
            {matchId}
            {match}
            {town1Stats}
            {town2Stats}
        />
    </div>
{/if}
