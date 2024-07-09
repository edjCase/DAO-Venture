<script lang="ts">
    import {
        LeagueChoiceScenarioOutcome,
        ScenarioResolvedOptionDiscrete,
    } from "../../../ic-agent/declarations/main";

    export let outcome: LeagueChoiceScenarioOutcome;
    export let options: ScenarioResolvedOptionDiscrete[];

    let optionName = options.find(
        (option) => option.id === outcome.optionId[0],
    )?.title;
</script>

<div class="text-xl text-center">
    {#if optionName === undefined}
        The league was not able to reach a consensus on an option
    {:else}
        The league has chosen option <div class="bold text-3xl">
            '{optionName}'
        </div>
    {/if}
</div>
