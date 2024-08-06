<script lang="ts">
    import { ClaimLocationContent } from "../../../../ic-agent/declarations/main";

    export let content: ClaimLocationContent;
    export let townId: bigint;
</script>

<div>
    Location Id: {content.locationId}
</div>
<div>
    Leave Location Id: {content.leaveLocationId}
</div>
