<script lang="ts">
    import {
        LeagueChoiceScenarioOutcome,
        LeagueChoiceScenario,
        ScenarioStateResolved,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";

    export let scenarioId: bigint;
    export let scenario: LeagueChoiceScenario;
    export let outcome: LeagueChoiceScenarioOutcome;
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
