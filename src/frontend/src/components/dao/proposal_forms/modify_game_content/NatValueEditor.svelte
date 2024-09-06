<script lang="ts">
  import { Input } from "flowbite-svelte";
  import { NatValue } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let value: NatValue;
</script>

{#if "raw" in value}
  <Input type="number" bind:value={value.raw} placeholder="Gold Amount" />
{:else if "random" in value}
  Random
{:else if "dataField" in value}
  TODO DATAFIELD
{:else}
  NOT IMPLMENEETED NAT VALUE : {toJsonString(value)}
{/if}
