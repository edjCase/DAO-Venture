<script lang="ts">
    import {
        ProportionalBidMetaEffect,
        ProportionalBidMetaEffectOutcome,
    } from "../../../ic-agent/declarations/league";
    import { Team } from "../../../ic-agent/declarations/teams";
    import { toJsonString } from "../../../utils/StringUtil";

    export let effect: ProportionalBidMetaEffect;
    export let outcome: ProportionalBidMetaEffectOutcome;
    export let teams: Team[];

    const getTeamName = (teamId: bigint) => {
        return teams.find((team) => team.id === teamId)?.name ?? "Unknown";
    };
</script>

{#each outcome.winningBids as bid}
    Prize: {effect.prize.amount} of {toJsonString(effect.prize.kind)}
    <div class="text-xl text-center">
        {getTeamName(bid.teamId)} got {bid.amount}
    </div>
{/each}
