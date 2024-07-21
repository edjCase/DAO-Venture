<script lang="ts">
    import { Label } from "flowbite-svelte";
    import BigIntInput from "../BigIntInput.svelte";
    import { toJsonString } from "../../../../utils/StringUtil";
    import { ProportionalBidScenario } from "../../../../ic-agent/declarations/main";
    export let value: ProportionalBidScenario;
</script>

<Label>Prize Amount</Label>
<BigIntInput bind:value={value.prize.amount} />
<Label>Prize Effect</Label>
NOT IMPLEMENTED PRIZE KIND : {toJsonString(value.prize.kind)}
