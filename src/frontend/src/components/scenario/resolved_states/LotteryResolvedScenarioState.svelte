<script lang="ts">
    import { LotteryScenarioOutcome } from "../../../ic-agent/declarations/main";
    import { Team } from "../../../ic-agent/declarations/main";
    import TeamLogo from "../../team/TeamLogo.svelte";

    export let outcome: LotteryScenarioOutcome;
    export let teams: Team[];

    console.log(teams);
    console.log(outcome);

    $: winningTeam =
        outcome.winningTeamId[0] !== undefined
            ? teams.find((team) => team.id === outcome.winningTeamId[0])
            : undefined;
</script>

<div class="text-xl text-center mb-8">
    Winner
    {#if winningTeam === undefined}
        <div>NONE</div>
    {:else}
        <TeamLogo team={winningTeam} size="md" />
    {/if}
</div>
