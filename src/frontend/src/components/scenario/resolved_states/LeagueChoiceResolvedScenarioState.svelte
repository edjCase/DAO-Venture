<script lang="ts">
    import {
        LeagueChoiceMetaEffect,
        LeagueChoiceMetaEffectOutcome,
    } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";

    export let effect: LeagueChoiceMetaEffect;
    export let outcome: LeagueChoiceMetaEffectOutcome;

    let chosenOption =
        outcome.optionId.length < 1
            ? undefined
            : effect.options[Number(outcome.optionId[0])];
</script>

<div class="text-xl text-center">
    The league has chosen option {toJsonString(chosenOption)}
</div>
