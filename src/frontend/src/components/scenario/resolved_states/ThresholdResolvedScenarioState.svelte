<script lang="ts">
    import {
        ThresholdMetaEffectOutcome,
        ThresholdScenario,
    } from "../../../ic-agent/declarations/league";

    export let scenario: ThresholdScenario;
    export let outcome: ThresholdMetaEffectOutcome;
</script>

{#if outcome.successful}
    <div class="text-xl text-center">Successful: Threshold Met</div>
    <div>{scenario.success.description}</div>
{:else}
    <div class="text-xl text-center">Failed: Threshold Not Met</div>
    <div>{scenario.failure.description}</div>
{/if}
