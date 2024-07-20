<script lang="ts">
    import { mainAgentFactory } from "../../ic-agent/Main";
    import {
        AddScenarioRequest,
        Scenario,
    } from "../../ic-agent/declarations/main";
    import { townStore } from "../../stores/TownStore";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { dateToNanoseconds } from "../../utils/DateUtils";
    import LoadingButton from "../common/LoadingButton.svelte";
    import ScenarioEditor from "./editors/ScenarioEditor.svelte";
    import { Button, Label, Select, Toggle } from "flowbite-svelte";
    import { toJsonString } from "../../utils/StringUtil";

    $: towns = $townStore;
    $: scenarios = $scenarioStore;

    let initialEnd = new Date(new Date().getTime() + 1000 * 60 * 60 * 24 * 3);
    let scenario: AddScenarioRequest = {
        title: "",
        description:
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed sem velit, eleifend vitae suscipit quis, convallis in libero. Vestibulum nec ullamcorper ligula. In nec sapien et sem porttitor congue sed sed felis. Etiam id ligula in metus rutrum tempor. Nunc eu laoreet eros, eget venenatis libero. Integer et nulla vel ante scelerisque tempus. Suspendisse ullamcorper lectus libero.",
        startTime: [],
        endTime: dateToNanoseconds(initialEnd),
        undecidedEffect: {
            entropy: {
                town: { contextual: null },
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
        if (!towns) {
            console.error("Towns have not loaded. Cannot add scenario.");
            return;
        }
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.addScenario(scenario);
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
