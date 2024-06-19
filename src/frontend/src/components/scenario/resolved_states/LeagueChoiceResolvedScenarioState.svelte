<script lang="ts">
    import {
        LeagueChoiceMetaEffect,
        LeagueChoiceMetaEffectOutcome,
    } from "../../../ic-agent/declarations/league";

    export let effect: LeagueChoiceMetaEffect;
    export let outcome: LeagueChoiceMetaEffectOutcome;
</script>

<div class="text-xl text-center">
    The league has chosen option {outcome.leagueChoice.optionId}
</div>
