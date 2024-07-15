<script lang="ts">
    import {
        CompletedMatch,
        CompletedMatchTeam,
    } from "../../ic-agent/declarations/main";
    import { teamStore } from "../../stores/TeamStore";
    import CompletedMatchCard, { TeamStats } from "./CompletedMatchCard.svelte";

    export let match: CompletedMatch;
    export let matchGroupId: number;
    export let matchId: number;
    $: teams = $teamStore;
    $: team1 = teams?.find((t) => t.id == match.team1.id);
    $: team2 = teams?.find((t) => t.id == match.team2.id);

    function compileTeamStats(team: CompletedMatchTeam): TeamStats {
        return {
            totalHits: team.playerStats.reduce(
                (sum, player) => sum + Number(player.battingStats.hits),
                0,
            ),
            totalRuns: team.playerStats.reduce(
                (sum, player) => sum + Number(player.battingStats.runs),
                0,
            ),
            totalHomeRuns: team.playerStats.reduce(
                (sum, player) => sum + Number(player.battingStats.homeRuns),
                0,
            ),
            totalStrikeouts: team.playerStats.reduce(
                (sum, player) => sum + Number(player.battingStats.strikeouts),
                0,
            ),
            totalPitches: team.playerStats.reduce(
                (sum, player) => sum + Number(player.pitchingStats.pitches),
                0,
            ),
            totalStrikes: team.playerStats.reduce(
                (sum, player) => sum + Number(player.pitchingStats.strikes),
                0,
            ),
        };
    }

    $: team1Stats = compileTeamStats(match.team1);
    $: team2Stats = compileTeamStats(match.team2);
</script>

{#if team1 && team2 && team1Stats && team2Stats}
    <div class="w-full flex justify-around">
        <CompletedMatchCard
            {matchGroupId}
            {matchId}
            {match}
            {team1Stats}
            {team2Stats}
        />
    </div>
{/if}
