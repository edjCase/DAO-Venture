<script lang="ts">
    import {
        LeagueChoiceMetaEffectOutcome,
        LeagueChoiceScenario,
    } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";

    export let scenario: LeagueChoiceScenario;
    export let outcome: LeagueChoiceMetaEffectOutcome;

    let chosenOption =
        outcome.optionId.length < 1
            ? undefined
            : scenario.options[Number(outcome.optionId[0])];
</script>

<div class="text-xl text-center">
    The league has chosen option {toJsonString(chosenOption)}
</div>
