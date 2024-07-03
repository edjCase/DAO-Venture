<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { ThresholdScenario } from "../../../ic-agent/declarations/league";

    export let scenario: ThresholdScenario;
</script>

<Label>On Sucess</Label>
<div>
    {scenario.success.description}
</div>

<Label>On Failure</Label>
<div>
    {scenario.failure.description}
</div>
