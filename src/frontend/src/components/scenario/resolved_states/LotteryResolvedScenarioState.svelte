<script lang="ts">
    import { LotteryScenarioOutcome } from "../../../ic-agent/declarations/league";
    import { Team } from "../../../ic-agent/declarations/teams";

    export let outcome: LotteryScenarioOutcome;
    export let teams: Team[];

    $: winningTeamName = outcome.winningTeamId[0]
        ? teams.find((team) => team.id === outcome.winningTeamId[0])?.name ||
          "Unknown"
        : undefined;
</script>

<div class="text-xl text-center">
    {#if winningTeamName === undefined}
        No team won the lottery
    {:else}
        {winningTeamName} won the lottery
    {/if}
</div>
