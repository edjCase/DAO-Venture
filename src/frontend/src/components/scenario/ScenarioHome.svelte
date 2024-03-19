<script lang="ts">
    import { scenarioStore } from "../../stores/ScenarioStore";
    import Scenario from "./Scenario.svelte";

    $: scenarios = $scenarioStore;

    $: inProgressScenarios = scenarios.filter(
        (scenario) => "inProgress" in scenario.state,
    );
</script>

{#each inProgressScenarios as scenario}
    <Scenario {scenario} />
{/each}
