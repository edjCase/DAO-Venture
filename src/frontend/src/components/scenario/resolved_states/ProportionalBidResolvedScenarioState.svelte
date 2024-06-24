<script lang="ts">
    import {
        ProportionalBidMetaEffectOutcome,
        ProportionalBidScenario,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import { Team } from "../../../ic-agent/declarations/teams";
    import { toJsonString } from "../../../utils/StringUtil";
    import ResolvedScenarioBids from "../ResolvedScenarioBids.svelte";

    export let scenarioId: bigint;
    export let scenario: ProportionalBidScenario;
    export let outcome: ProportionalBidMetaEffectOutcome;
    export let vote: ScenarioVote | "ineligible";
    export let teams: Team[];

    const getTeamName = (teamId: bigint) => {
        return teams.find((team) => team.id === teamId)?.name ?? "Unknown";
    };
</script>

{#each outcome.winningBids as bid}
    Prize: {scenario.prize.amount} of {toJsonString(scenario.prize.kind)}
    <div class="text-xl text-center">
        {getTeamName(bid.teamId)} got {bid.amount}
    </div>
{/each}

<ResolvedScenarioBids {scenarioId} {bids} {vote} />
