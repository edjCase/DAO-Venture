<script lang="ts">
  import { Input } from "flowbite-svelte";
  import { TextValue } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let value: TextValue;
</script>

{#if "raw" in value}
  <Input type="text" bind:value={value.raw} />
{:else if "dataField" in value}
  TODO DATA FIELD
{:else if "weighted" in value}
  TODO WEIGHTED
{:else}
  NOT IMPLEMENTED TEXT VALUE : {toJsonString(value)}
{/if}
