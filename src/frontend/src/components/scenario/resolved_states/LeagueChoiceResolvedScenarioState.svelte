<script lang="ts">
    import {
        WorldChoiceScenarioOutcome,
        ScenarioResolvedOptionDiscrete,
    } from "../../../ic-agent/declarations/main";

    export let outcome: WorldChoiceScenarioOutcome;
    export let options: ScenarioResolvedOptionDiscrete[];

    let optionName = options.find(
        (option) => option.id === outcome.optionId[0],
    )?.title;
</script>

<div class="text-xl text-center">
    {#if optionName === undefined}
        The world was not able to reach a consensus on an option
    {:else}
        The world has chosen option <div class="bold text-3xl">
            '{optionName}'
        </div>
    {/if}
</div>
