<script lang="ts">
    import { LotteryScenario } from "../../../ic-agent/declarations/main";

    export let scenario: LotteryScenario;
</script>

<div>Prize: {scenario.prize.description}</div>
{#if scenario.minBid > 0}
    <div>Minimum Bid: {scenario.minBid}</div>
{/if}
