<script lang="ts">
    import {
        LotteryMetaEffect,
        LotteryMetaEffectOutcome,
    } from "../../../ic-agent/declarations/league";
    import { Team } from "../../../ic-agent/declarations/teams";
    import { toJsonString } from "../../../utils/StringUtil";

    export let effect: LotteryMetaEffect;
    export let outcome: LotteryMetaEffectOutcome;
    export let teams: Team[];

    $: winningTeamName = outcome.winningTeamId
        ? teams.find((team) => team.id === outcome.winningTeamId[0])?.name ||
          "Unknown"
        : undefined;
</script>

<div class="text-xl text-center">
    {#if winningTeamName === undefined}
        No team won the lottery
    {:else}
        {winningTeamName} won the lottery of {toJsonString(effect.prize)}
    {/if}
</div>
