<script lang="ts">
    import { SwapPlayerPositionsContent } from "../../../../ic-agent/declarations/main";
    import { fieldPositionToString } from "../../../../models/FieldPosition";

    export let content: SwapPlayerPositionsContent;
</script>

<div>Position 1: {fieldPositionToString(content.position1)}</div>
<div>Position 2: {fieldPositionToString(content.position2)}</div>
