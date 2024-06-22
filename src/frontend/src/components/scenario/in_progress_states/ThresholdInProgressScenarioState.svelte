<script lang="ts">
    import {
        ScenarioVote,
        ThresholdScenario,
    } from "../../../ic-agent/declarations/league";
    import InProgressScenarioOptions from "../InProgressScenarioOptions.svelte";

    export let scenario: ThresholdScenario;
    export let scenarioId: bigint;
    export let vote: ScenarioVote;

    let options = scenario.options;
</script>

<InProgressScenarioOptions {vote} {scenarioId} {options} />
