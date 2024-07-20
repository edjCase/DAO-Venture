<script lang="ts">
    import {
        ProportionalBidScenarioOutcome,
        ProportionalBidScenario,
    } from "../../../ic-agent/declarations/main";
    import { Town } from "../../../ic-agent/declarations/main";

    export let scenario: ProportionalBidScenario;
    export let outcome: ProportionalBidScenarioOutcome;
    export let towns: Town[];

    const getTownName = (townId: bigint) => {
        return towns.find((town) => town.id === townId)?.name ?? "Unknown";
    };
</script>

{#each outcome.bids as bid}
    Prize: {scenario.prize.description}
    <div class="text-xl text-center">
        {getTownName(bid.townId)} got {bid.proportion}
    </div>
{/each}
