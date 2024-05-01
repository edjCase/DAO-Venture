<script lang="ts">
    import { leagueAgentFactory } from "../../ic-agent/League";
    import { AddScenarioRequest } from "../../ic-agent/declarations/league";
    import { teamStore } from "../../stores/TeamStore";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { dateToNanoseconds } from "../../utils/DateUtils";
    import LoadingButton from "../common/LoadingButton.svelte";
    import ScenarioEditor from "./editors/ScenarioEditor.svelte";

    $: teams = $teamStore;

    let initialStart = new Date();
    let initialEnd = new Date(initialStart.getTime() + 1000 * 60 * 60 * 24);
    let scenario: AddScenarioRequest = {
        title: "",
        description: "",
        teamIds: [],
        startTime: dateToNanoseconds(initialStart),
        endTime: dateToNanoseconds(initialEnd),
        options: [
            {
                title: "",
                description: "",
                energyCost: BigInt(0),
                effect: {
                    noEffect: null,
                },
            },
            {
                title: "",
                description: "",
                energyCost: BigInt(0),
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
</script>

<ScenarioEditor bind:value={scenario} />
<div class="mt-4">
    <LoadingButton onClick={addScenario}>Add Scenario</LoadingButton>
</div>
