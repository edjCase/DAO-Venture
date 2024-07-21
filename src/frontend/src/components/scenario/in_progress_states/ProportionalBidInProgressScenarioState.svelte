<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { ProportionalBidScenario } from "../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../utils/StringUtil";

    export let scenario: ProportionalBidScenario;
</script>

<Label>Prize</Label>
{scenario.prize.amount}
NOT IMPLEMENTED PRIZE: {toJsonString(scenario.prize.kind)}
