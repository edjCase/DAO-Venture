<script lang="ts">
    import { Label } from "flowbite-svelte";
    import {
        ProportionalBidScenario,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import InProgressScenarioBids from "../InProgressScenarioBids.svelte";
    import { toJsonString } from "../../../utils/StringUtil";

    export let scenarioId: bigint;
    export let scenario: ProportionalBidScenario;
    export let vote: ScenarioVote;
    export let bids: bigint[];
</script>

<Label>Prize</Label>
{scenario.prize.amount}
{#if "skill" in scenario.prize.kind}
    {scenario.prize.kind.skill.skill} for {scenario.prize.kind.skill.duration} days
{:else}
    NOT IMPLEMENTED PRIZE: {toJsonString(scenario.prize.kind)}
{/if}

<InProgressScenarioBids {scenarioId} minBid={BigInt(0)} {vote} {bids} />
