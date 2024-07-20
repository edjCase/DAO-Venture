<script lang="ts">
    import { TownOrUndetermined } from "../../models/Town";
    import TownLogo from "../town/TownLogo.svelte";

    export let town: TownOrUndetermined;
    export let score: bigint | undefined;
</script>

<div class="flex items-center jusity-center">
    <div class="mr-2">
        <TownLogo {town} size="xxs" border={true} padding={false} />
    </div>
    <div>
        {score == undefined ? "-" : score.toString()}
    </div>
</div>
