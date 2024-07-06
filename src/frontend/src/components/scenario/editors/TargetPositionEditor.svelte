<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { TargetPosition } from "../../../ic-agent/declarations/main";
    import ChosenOrRandomFieldPositionChooser from "./ChosenOrRandomFieldPositionChooser.svelte";
    import TargetTeamChooser from "./TargetTeamChooser.svelte";

    export let value: TargetPosition;
</script>

<Label>Team</Label>
<TargetTeamChooser bind:value={value.team} />
<Label>Position</Label>
<ChosenOrRandomFieldPositionChooser bind:value={value.position} />
