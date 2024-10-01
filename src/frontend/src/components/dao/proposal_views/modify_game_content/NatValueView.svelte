<script lang="ts">
  import { NatValue } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let value: NatValue;
</script>

<div>
  {#if "raw" in value}
    {value.raw}
  {:else if "random" in value}
    Random: {value.random[0]} - {value.random[1]}
  {:else}
    NOT IMPLEMENTED NAT VALUE: {toJsonString(value)}
  {/if}
</div>
