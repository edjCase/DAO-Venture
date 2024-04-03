<script lang="ts">
    import { SwapPlayerPositionsContent } from "../../../../ic-agent/declarations/teams";
    import { toEnum } from "../../../../models/FieldPosition";

    export let content: SwapPlayerPositionsContent;
</script>

<div>Position 1: {toEnum(content.position1)}</div>
<div>Position 2: {toEnum(content.position2)}</div>
