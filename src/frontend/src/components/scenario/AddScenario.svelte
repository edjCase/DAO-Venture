<script lang="ts">
    import { leagueAgentFactory } from "../../ic-agent/League";
    import {
        AddScenarioRequest,
        Scenario,
    } from "../../ic-agent/declarations/league";
    import { teamStore } from "../../stores/TeamStore";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { dateToNanoseconds } from "../../utils/DateUtils";
    import LoadingButton from "../common/LoadingButton.svelte";
    import ScenarioEditor from "./editors/ScenarioEditor.svelte";
    import { Button, Label, Select, Toggle } from "flowbite-svelte";
    import { toJsonString } from "../../utils/StringUtil";

    $: teams = $teamStore;
    $: scenarios = $scenarioStore;

    let initialEnd = new Date(new Date().getTime() + 1000 * 60 * 60 * 24 * 3);
    let scenario: AddScenarioRequest = {
        title: "Scenario 1",
        description: "Scenario Description",
        startTime: [],
        endTime: dateToNanoseconds(initialEnd),
        undecidedEffect: {
            entropy: {
                target: { contextual: null },
                delta: BigInt(1),
            },
        },
        kind: {
            noLeagueEffect: {
                options: [],
            },
        },
    };

    let addScenario = async () => {
        if (!scenario) {
            console.error("Scenario not loaded. Cannot add scenario.");
            return;
        }
        if (!teams) {
            console.error("Teams have not loaded. Cannot add scenario.");
            return;
        }
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.addScenario(scenario);
        if ("ok" in result) {
            console.log("Created scenario: ", scenario);
            scenarioStore.refetch();
        } else {
            console.error("Failed to make scenario: ", scenario, result);
        }
    };

    let loadScenario = async () => {
        if (!selectedScenario) {
            console.error("No scenario selected. Cannot load scenario.");
            return;
        }
        scenario = {
            title: selectedScenario.title,
            description: selectedScenario.description,
            startTime: scenario.startTime, // Keep the same start time
            endTime: scenario.endTime, // Keep the same end time
            undecidedEffect: selectedScenario.undecidedEffect,
            kind: selectedScenario.kind,
        };
    };

    let showRaw = false;

    let selectedScenario: Scenario | undefined = undefined;

    $: scenarioItems =
        scenarios?.map((scenario) => {
            return {
                value: scenario,
                name: scenario.title,
            };
        }) ?? [];

    $: rawScenario = showRaw ? toJsonString(scenario, true) : "";
</script>

<Select items={scenarioItems} bind:value={selectedScenario} />
<Button on:click={loadScenario}>Load Scenario</Button>
<Label>Show Raw Scenario</Label>
<Toggle bind:checked={showRaw} />
{#if showRaw}
    <pre>{rawScenario}</pre>
{/if}

<ScenarioEditor bind:value={scenario} />
<div class="mt-4">
    <LoadingButton onClick={addScenario}>Add Scenario</LoadingButton>
</div>
