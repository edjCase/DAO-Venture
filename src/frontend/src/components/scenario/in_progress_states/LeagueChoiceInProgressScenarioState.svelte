<script lang="ts">
    import {
        LeagueChoiceScenario,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import InProgressScenarioOptions from "../InProgressScenarioOptions.svelte";

    export let scenario: LeagueChoiceScenario;
    export let scenarioId: bigint;
    export let vote: ScenarioVote;

    let options = scenario.options;
</script>

<InProgressScenarioOptions {vote} {scenarioId} {options} />
