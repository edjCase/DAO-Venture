<script lang="ts">
    import { Button, Input, Select, SelectOptionType } from "flowbite-svelte";
    import { scenarios } from "../../data/ScenarioData";
    import { leagueAgentFactory } from "../../ic-agent/League";
    import { AddScenarioRequest } from "../../ic-agent/declarations/league";
    import { teamStore } from "../../stores/TeamStore";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { dateToNanoseconds } from "../../utils/DateUtils";

    let items: SelectOptionType<number>[] = scenarios.map((scenario, index) => {
        return {
            name: scenario.title,
            value: index,
        };
    });

    $: teams = $teamStore;

    let selectedIndex = 0;
    let id = "S1";

    let initialStart = new Date();
    let initialEnd = new Date(initialStart.getTime() + 1000 * 60);

    let formatDateTimeLocal = (date: Date) => {
        let year = date.getFullYear();
        let month = (date.getMonth() + 1).toString().padStart(2, "0");
        let day = date.getDate().toString().padStart(2, "0");
        let hours = date.getHours().toString().padStart(2, "0");
        let minutes = date.getMinutes().toString().padStart(2, "0");
        return `${year}-${month}-${day}T${hours}:${minutes}`;
    };

    let startTime = formatDateTimeLocal(initialStart);
    let endTime = formatDateTimeLocal(initialEnd);

    let addScenario = async () => {
        let request: AddScenarioRequest = {
            id: id,
            startTime: dateToNanoseconds(new Date(startTime)),
            endTime: dateToNanoseconds(new Date(endTime)),
            title: scenarios[selectedIndex].title,
            description: scenarios[selectedIndex].description,
            options: scenarios[selectedIndex].options,
            metaEffect: scenarios[selectedIndex].metaEffect,
            teamIds: teams.map((team) => team.id), // TODO make configurable
        };
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.addScenario(request);
        if ("ok" in result) {
            console.log("Created scenario: ", id);
            scenarioStore.refetch();
        } else {
            console.error("Failed to make scenario: ", id, result);
        }
    };
</script>

<Select {items} bind:value={selectedIndex} />

<Input type="text" bind:value={id} />
<Input type="datetime-local" bind:value={startTime} />
<Input type="datetime-local" bind:value={endTime} />

<Button on:click={addScenario}>Add Scenario</Button>
