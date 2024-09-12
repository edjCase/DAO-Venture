<script lang="ts">
  import { TargetKind } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";

  export let value: TargetKind;
</script>

{#if "character" in value}
  You
{:else if "creature" in value}
  C{value.creature}
{:else if "periodicEffect" in value}
  Periodic Effect
{:else}
  NOT IMPLEMENTED TARGET TYPE {toJsonString(value)}
{/if}
