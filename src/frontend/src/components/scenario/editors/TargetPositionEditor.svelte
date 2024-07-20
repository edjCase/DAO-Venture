<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { TargetPosition } from "../../../ic-agent/declarations/main";
    import ChosenOrRandomFieldPositionChooser from "./ChosenOrRandomFieldPositionChooser.svelte";
    import TargetTownChooser from "./TargetTownChooser.svelte";

    export let value: TargetPosition;
</script>

<Label>Town</Label>
<TargetTownChooser bind:value={value.town} />
<Label>Position</Label>
<ChosenOrRandomFieldPositionChooser bind:value={value.position} />
