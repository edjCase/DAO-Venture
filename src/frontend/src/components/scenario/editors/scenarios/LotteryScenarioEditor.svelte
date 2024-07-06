<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import ScenarioEffectChooser from "../ScenarioEffectChooser.svelte";
    import { LotteryScenario } from "../../../../ic-agent/declarations/main";
    export let value: LotteryScenario;
</script>

<Label>Prize Description</Label>
<Input type="text" bind:value={value.prize.description} />
<Label>Prize Effect</Label>
<ScenarioEffectChooser bind:value={value.prize.effect} />
<Label>Min Bid</Label>
<Input type="number" bind:value={value.minBid} />
