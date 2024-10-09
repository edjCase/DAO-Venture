<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { ScenarioKind } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";

  export let value: ScenarioKind;
</script>

{#if "combat" in value}
  {@const combatScenario = value.combat}

  {#if "normal" in combatScenario}
    <span>🗡️</span>
    <Tooltip>
      <div class="text-xl text-primary-500">Normal Combat</div>
    </Tooltip>
  {:else if "elite" in combatScenario}
    <span>⚔️</span>
    <Tooltip>
      <div class="text-xl text-primary-500">Elite Combat</div>
    </Tooltip>
  {:else if "boss" in combatScenario}
    <span>🐉</span>
    <Tooltip>
      <div class="text-xl text-primary-500">Boss Combat</div>
    </Tooltip>
  {:else}
    NOT IMPLEMENTED COMBAT SCENARIO {toJsonString(combatScenario)}
  {/if}
{:else if "store" in value}
  <span>🛖</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Store</div>
  </Tooltip>
{:else if "encounter" in value}
  <span>💭</span>
  <Tooltip>
    <div class="text-xl text-primary-500">Encounter</div>
  </Tooltip>
{:else}
  NOT IMPLEMENTED NEXT PATH KIND {toJsonString(value)}
{/if}
