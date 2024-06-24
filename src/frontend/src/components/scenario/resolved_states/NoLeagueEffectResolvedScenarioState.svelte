<script lang="ts">
    import {
        NoLeagueEffectScenario,
        ScenarioStateResolved,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import ResolvedScenarioOptions from "../ResolvedScenarioOptions.svelte";

    export let scenarioId: bigint;
    export let scenario: NoLeagueEffectScenario;
    export let state: ScenarioStateResolved;
    export let vote: ScenarioVote | "ineligible";
</script>

<ResolvedScenarioOptions
    {scenarioId}
    options={scenario.options}
    {state}
    {vote}
/>
