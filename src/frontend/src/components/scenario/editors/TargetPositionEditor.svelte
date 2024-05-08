<script lang="ts">
    import { TargetPosition } from "../../../ic-agent/declarations/league";
    import ChosenOrRandomFieldPositionChooser from "./ChosenOrRandomFieldPositionChooser.svelte";
    import TargetTeamChooser from "./TargetTeamChooser.svelte";

    export let value: TargetPosition;
</script>

<TargetTeamChooser bind:value={value.team} />
<ChosenOrRandomFieldPositionChooser bind:value={value.position} />
