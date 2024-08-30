<script lang="ts">
  import { UnlockRequirement } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let value: [] | [UnlockRequirement];
</script>

<div>
  Unlock Requirement:
  {#if value[0] === undefined}
    None
  {:else}
    {@const unlockRequirement = value[0]}
    {#if "acheivementId" in unlockRequirement}
      <div>Acheivement: {unlockRequirement.acheivementId}</div>
    {:else}
      NOT IMPLEMENTED UNLOCK REQUIREMENT: <pre>{toJsonString(
          unlockRequirement
        )}</pre>
    {/if}
  {/if}
</div>
