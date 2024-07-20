<script lang="ts">
    import { TownOrUndetermined } from "../../models/Town";
    import TeamFlag from "../town/TeamFlag.svelte";

    export let town: TownOrUndetermined;
    export let score: bigint | undefined;
</script>

<div class="flex items-center jusity-center">
    <div class="mr-2">
        <TeamFlag {town} size="xxs" border={true} padding={false} />
    </div>
    <div>
        {score == undefined ? "-" : score.toString()}
    </div>
</div>
