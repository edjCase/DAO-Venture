<script lang="ts">
    import { TownOrUndetermined } from "../../models/Town";
    import TeamFlag from "../town/TeamFlag.svelte";

    export let town1: TownOrUndetermined;
    export let town2: TownOrUndetermined;
</script>

<div class="flex items-center justify-center text-center">
    <TeamFlag town={town1} size="xs" name="left" />
    <span class="text-gray-500 mx-1">vs</span>
    <TeamFlag town={town2} size="xs" name="right" />
</div>
