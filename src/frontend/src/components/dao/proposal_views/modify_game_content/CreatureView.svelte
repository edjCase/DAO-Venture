<script lang="ts">
  import { toJsonString } from "../../../../utils/StringUtil";
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import { Creature } from "../../../../ic-agent/declarations/main";

  export let creature: Creature;
</script>

<div>
  <div class="text-xl text-primary-500 font-bold">Creature</div>
  <EntityView entity={creature} />
  <div class="text-primary-500">Health</div>
  <div>Starting - {creature.health}</div>
  <div>Max - {creature.maxHealth}</div>
  <div class="text-primary-500">Weapon</div>
  <div class="text-primary-500">Actions</div>
  <div>{creature.actionIds.join(", ")}</div>
  <div class="text-primary-500">Kind</div>
  <div>
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
  <div class="text-primary-500">Location</div>
  <div class="pl-8">
    {#if "common" in creature.location}
      Everywhere
    {:else if "zoneIds" in creature.location}
      <div class="text-primary-500">Zones</div>
      <div>{creature.location.zoneIds.join(", ")}</div>
    {:else}
      NOT IMPLEMENTED CREATURE LOCATION: <pre>{toJsonString(
          creature.location
        )}</pre>
    {/if}
  </div>
  <div class="text-primary-500">Unlock Requirement</div>
  <UnlockRequirementView value={creature.unlockRequirement} />
</div>
