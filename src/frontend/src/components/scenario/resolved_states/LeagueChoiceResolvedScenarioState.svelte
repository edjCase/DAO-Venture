<script lang="ts">
    import {
        LeagueChoiceMetaEffectOutcome,
        LeagueChoiceScenario,
        ScenarioStateResolved,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";
    import ResolvedScenarioOptions from "../ResolvedScenarioOptions.svelte";

    export let scenarioId: bigint;
    export let scenario: LeagueChoiceScenario;
    export let outcome: LeagueChoiceMetaEffectOutcome;
    export let state: ScenarioStateResolved;
    export let vote: ScenarioVote | "ineligible";

    let chosenOption =
        outcome.optionId.length < 1
            ? undefined
            : scenario.options[Number(outcome.optionId[0])];
</script>

<div class="text-xl text-center">
    The league has chosen option {toJsonString(chosenOption)}
</div>

<ResolvedScenarioOptions
    {scenarioId}
    options={scenario.options}
    {state}
    {vote}
/>
