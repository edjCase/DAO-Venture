<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import ScenarioEffectChooser from "../ScenarioEffectChooser.svelte";
    import { LotteryScenario } from "../../../../ic-agent/declarations/league";
    export let value: LotteryScenario;
</script>

<Label>Prize</Label>
<ScenarioEffectChooser bind:value={value.prize} />
<Label>Min Bid</Label>
<Input type="number" bind:value={value.minBid} />
