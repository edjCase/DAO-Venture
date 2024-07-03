<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { LotteryScenario } from "../../../ic-agent/declarations/league";

    export let scenario: LotteryScenario;
</script>

<Label>Minimum Bid</Label>
<div>{scenario.minBid}</div>
<Label>Prize</Label>
<div>{scenario.prize.description}</div>
