<script lang="ts">
    import {
        LotteryScenario,
        ScenarioVote,
    } from "../../../ic-agent/declarations/league";
    import InProgressScenarioBids from "../InProgressScenarioBids.svelte";

    export let scenarioId: bigint;
    export let scenario: LotteryScenario;
    export let vote: ScenarioVote;
</script>

<InProgressScenarioBids {scenarioId} minBid={scenario.minBid} {vote} />
