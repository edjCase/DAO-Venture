<script lang="ts">
    import {
        ThresholdScenarioOutcome,
        ThresholdScenario,
    } from "../../../ic-agent/declarations/league";

    export let scenario: ThresholdScenario;
    export let outcome: ThresholdScenarioOutcome;
</script>

{#if outcome.successful}
    <div class="text-xl text-center">Successful: Threshold Met</div>
    <div>{scenario.success.description}</div>
{:else}
    <div class="text-xl text-center">Failed: Threshold Not Met</div>
    <div>{scenario.failure.description}</div>
{/if}
