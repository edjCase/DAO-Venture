<script lang="ts">
    import { TargetPosition } from "../../../ic-agent/declarations/league";
    import FieldPositionChooser from "./FieldPositionChooser.svelte";
    import TargetTeamChooser from "./TargetTeamChooser.svelte";

    export let value: TargetPosition;
</script>

<TargetTeamChooser bind:value={value.team} />
<FieldPositionChooser bind:value={value.position} />
