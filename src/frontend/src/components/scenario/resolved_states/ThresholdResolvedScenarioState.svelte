<script lang="ts">
    import {
        ScenarioStateResolved,
        ScenarioVote,
        ThresholdMetaEffectOutcome,
        ThresholdScenario,
    } from "../../../ic-agent/declarations/league";
    import ResolvedScenarioOptions from "../ResolvedScenarioOptions.svelte";

    export let scenarioId: bigint;
    export let scenario: ThresholdScenario;
    export let outcome: ThresholdMetaEffectOutcome;
    export let state: ScenarioStateResolved;
    export let vote: ScenarioVote | "ineligible";
</script>

{#if outcome.successful}
    <div class="text-xl text-center">Successful: Threshold Met</div>
    <div>{scenario.success.description}</div>
{:else}
    <div class="text-xl text-center">Failed: Threshold Not Met</div>
    <div>{scenario.failure.description}</div>
{/if}

<ResolvedScenarioOptions
    {scenarioId}
    options={scenario.options}
    {state}
    {vote}
/>
