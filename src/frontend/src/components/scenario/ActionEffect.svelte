<script lang="ts">
  import { ActionEffect } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import GameIcon from "../game/GameIcon.svelte";
  import StatusEffect from "./StatusEffect.svelte";
  import TimingIcon from "./TimingIcon.svelte";
  export let value: ActionEffect;
</script>

{#if "addStatusEffect" in value.kind}
  <StatusEffect value={value.kind.addStatusEffect} />
{:else if "block" in value.kind}
  <GameIcon value="block" />
  {value.kind.block.min} - {value.kind.block.max}
  <TimingIcon value={value.kind.block.timing} />
{:else if "damage" in value.kind}
  <GameIcon value="damage" />
  {value.kind.damage.min} - {value.kind.damage.max}
  <TimingIcon value={value.kind.damage.timing} />
{:else if "heal" in value.kind}
  <GameIcon value="heal" />
  {value.kind.heal.min} - {value.kind.heal.max}
  <TimingIcon value={value.kind.heal.timing} />
{:else}
  NOT IMPLEMENTED EFFECT KINDS {toJsonString(value.kind)}
{/if}
{#if "self" in value.target}
  <GameIcon value="self" />
{:else if "targets" in value.target}
  <!-- No Icon -->
{:else}
  NOT IMPLEMENTED TARGET {toJsonString(value.target)}
{/if}
