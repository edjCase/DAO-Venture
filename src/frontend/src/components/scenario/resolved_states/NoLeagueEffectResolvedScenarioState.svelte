<script lang="ts">
    import {
        NoLeagueEffectScenario,
        ScenarioStateResolved,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";

    export let scenarioId: bigint;
    export let scenario: NoLeagueEffectScenario;
    export let state: ScenarioStateResolved;
    export let vote: ScenarioVote | "ineligible";
</script>
