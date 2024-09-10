<script lang="ts">
  import { RandomOrSpecificTextValue } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import TextValueEditor from "./TextValueEditor.svelte";
  export let value: RandomOrSpecificTextValue;
</script>

{#if "random" in value}
  <div>Random</div>
{:else if "specific" in value}
  <TextValueEditor bind:value={value.specific} />
{:else}
  NOT IMPLEMENTED RANDOM OR SPECIFIC TEXT VALUE: {toJsonString(value)}
{/if}
