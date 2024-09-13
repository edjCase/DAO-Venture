<script lang="ts">
  import { Condition } from "../../../../ic-agent/declarations/main";
  import { itemStore } from "../../../../stores/ItemStore";
  import { toJsonString } from "../../../../utils/StringUtil";
  import BigIntInput from "../../../common/BigIntInput.svelte";
  import EntitySelector from "./EntitySelector.svelte";
  export let value: Condition;
</script>

{#if "hasGold" in value}
  <BigIntInput bind:value={value.hasGold} />
{:else if "hasItem" in value}
  <EntitySelector bind:value={value.hasItem} store={itemStore} label="Item" />
{:else}
  NOT IMPLEMENTED CONDITION : {toJsonString(value)}
{/if}
