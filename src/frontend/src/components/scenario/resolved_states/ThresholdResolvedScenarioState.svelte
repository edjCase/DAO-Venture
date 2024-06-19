<script lang="ts">
    import {
        ThresholdMetaEffect,
        ThresholdMetaEffectOutcome,
    } from "../../../ic-agent/declarations/league";

    export let effect: ThresholdMetaEffect;
    export let outcome: ThresholdMetaEffectOutcome;
</script>

{#if outcome.successful}
    <div class="text-xl text-center">Successful: Threshold Met</div>
    <div>{effect.success.description}</div>
{:else}
    <div class="text-xl text-center">Failed: Threshold Not Met</div>
    <div>{effect.failure.description}</div>
{/if}
