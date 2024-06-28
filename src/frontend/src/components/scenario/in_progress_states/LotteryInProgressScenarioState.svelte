<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { LotteryScenario } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";

    export let scenario: LotteryScenario;
</script>

<Label>Prize</Label>
{toJsonString(scenario.prize)}
