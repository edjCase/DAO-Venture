<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import Scenario from "./Scenario.svelte";

    $: scenarios = $scenarioStore;

    $: inProgressScenarios = scenarios.filter(
        (scenario) => "inProgress" in scenario.state,
    );

    $: resolvedScenarios = scenarios.filter(
        (scenario) => "resolved" in scenario.state,
    );

    let selectedIndex = 0;

    $: resolvedItems = resolvedScenarios.map((scenario, index) => {
        return {
            name: scenario.title,
            value: index,
        };
    });
</script>

<div>
    <div class="mt-5 mb-5">
        {#if inProgressScenarios.length <= 0}
            <div class="text-3xl text-center">No Active Scenarios</div>
        {:else}
            {#each inProgressScenarios as scenario}
                <Scenario {scenario} />
            {/each}
        {/if}
    </div>
    {#if resolvedScenarios.length > 0}
        <hr />
        <div class="pt-5">
            <div class="text-3xl text-center mb-5">Historical</div>
            <Select items={resolvedItems} bind:value={selectedIndex} />

            <Scenario scenario={resolvedScenarios[selectedIndex]} />
        </div>
    {/if}
</div>
