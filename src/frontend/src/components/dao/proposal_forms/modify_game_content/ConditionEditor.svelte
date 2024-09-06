<script lang="ts">
  import { Condition } from "../../../../ic-agent/declarations/main";
  import NatValueEditor from "./NatValueEditor.svelte";
  import { toJsonString } from "../../../../utils/StringUtil";
  import TextValueEditor from "./TextValueEditor.svelte";
  export let value: Condition;
</script>

{#if "hasGold" in value}
  <NatValueEditor bind:value={value.hasGold} />
{:else if "hasItem" in value}
  <TextValueEditor bind:value={value.hasItem} />
{:else if "hasTrait" in value}
  <TextValueEditor bind:value={value.hasTrait} />
{:else}
  NOT IMPLEMENTED CONDITION : {toJsonString(value)}
{/if}
