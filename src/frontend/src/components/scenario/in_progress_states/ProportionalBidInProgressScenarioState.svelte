<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { ProportionalBidScenario } from "../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../utils/StringUtil";

    export let scenario: ProportionalBidScenario;
</script>

<Label>Prize</Label>
{scenario.prize.amount}
{#if "skill" in scenario.prize.kind}
    {scenario.prize.kind.skill.skill} for {scenario.prize.kind.skill.duration} days
{:else}
    NOT IMPLEMENTED PRIZE: {toJsonString(scenario.prize.kind)}
{/if}
