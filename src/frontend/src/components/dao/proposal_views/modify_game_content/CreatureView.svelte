<script lang="ts">
  import { toJsonString } from "../../../../utils/StringUtil";
  import EntityView from "./EntityView.svelte";
  import ActionsView from "./ActionsView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import { Creature } from "../../../../ic-agent/declarations/main";

  export let creature: Creature;
</script>

<div>
  <div>Creature</div>
  <EntityView entity={creature} />
  <ActionsView actionIds={creature.actionIds} />
  <div>
    Kind:
    {#if "normal" in creature.kind}
      Normal
    {:else if "elite" in creature.kind}
      Elite
    {:else if "boss" in creature.kind}
      Boss
    {:else}
      NOT IMPLEMENTED CREATURE KIND: <pre>{toJsonString(creature.kind)}</pre>
    {/if}
  </div>
  <div>
    Location:
    {#if "common" in creature.location}
      Everywhere
    {:else if "zoneIds" in creature.location}
      Zones:
      {#each creature.location.zoneIds as zoneId}
        {zoneId}
      {/each}
    {:else}
      NOT IMPLEMENTED CREATURE LOCATION: <pre>{toJsonString(
          creature.location
        )}</pre>
    {/if}
    <UnlockRequirementView value={creature.unlockRequirement} />
  </div>
</div>
