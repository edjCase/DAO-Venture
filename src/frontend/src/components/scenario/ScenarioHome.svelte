<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { navigate } from "svelte-routing";
    import { Scenario } from "../../ic-agent/declarations/league";
    import { scenarioStore } from "../../stores/ScenarioStore";
    let activeScenarios: Scenario[] = [];

    scenarioStore.subscribe((scenarios) => {
        activeScenarios = scenarios.filter(
            (scenario) => "inProgress" in scenario.state,
        );
    });
</script>

<div>
    <div class="text-3xl text-center mb-5">Scenarios</div>
    {#if activeScenarios.length == 0}
        <div class="text-xl text-center">Next scenario in ???</div>
    {:else}
        <div class="flex flex-col items-center">
            {#each activeScenarios as scenario}
                <Button on:click={() => navigate("/scenarios")}>
                    {scenario.title}
                </Button>
            {/each}
        </div>
    {/if}
    <div class="flex justify-center"></div>
</div>
