<script lang="ts">
    import {
        NoLeagueEffectScenario,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import InProgressScenarioOptions from "../InProgressScenarioOptions.svelte";

    export let scenario: NoLeagueEffectScenario;
    export let scenarioId: bigint;
    export let vote: ScenarioVote;

    let options = scenario.options;
</script>

<InProgressScenarioOptions {vote} {scenarioId} {options} />
