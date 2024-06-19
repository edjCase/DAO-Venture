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
        title: "",
        description: "",
        teamIds: [],
        startTime: [],
        endTime: dateToNanoseconds(initialEnd),
        undecidedEffect: {
            entropy: {
                target: { choosingTeam: null },
                delta: BigInt(1),
            },
        },
        options: [
            {
                title: "",
                description: "",
                energyCost: BigInt(0),
                traitRequirements: [],
                effect: {
                    noEffect: null,
                },
            },
            {
                title: "",
                description: "",
                energyCost: BigInt(0),
                traitRequirements: [],
                effect: {
                    noEffect: null,
                },
            },
        ],
        metaEffect: {
            noEffect: null,
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
        scenario.teamIds = teams.map((team) => team.id); // TODO
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
            teamIds: [],
            startTime: scenario.startTime, // Keep the same start time
            endTime: scenario.endTime, // Keep the same end time
            undecidedEffect: selectedScenario.undecidedEffect,
            options: selectedScenario.options,
            metaEffect: selectedScenario.metaEffect,
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
