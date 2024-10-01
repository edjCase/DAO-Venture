<script lang="ts">
  import { UnlockRequirement } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let value: UnlockRequirement;
</script>

<div>
  {#if "achievementId" in value}
    Acheivement: {value.achievementId}
  {:else if "none" in value}
    -
  {:else}
    NOT IMPLEMENTED UNLOCK REQUIREMENT: {toJsonString(value)}
  {/if}
</div>
