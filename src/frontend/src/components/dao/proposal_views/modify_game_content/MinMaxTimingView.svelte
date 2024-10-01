<script lang="ts">
  import { ActionTimingKind } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";

  export let value: { min: bigint; max: bigint; timing: ActionTimingKind };
</script>

{#if value.min === value.max}
  {value.min}
{:else}
  {value.min}-{value.max}
{/if}
{#if "periodic" in value.timing}
  at the
  {#if "start" in value.timing.periodic.phase}
    start
  {:else if "end" in value.timing.periodic.phase}
    end
  {:else}
    NOT IMPLEMENTED PERIODIC TIMING: {toJsonString(value.timing.periodic)}
  {/if}
  of each turn over {value.timing.periodic.turnDuration} turns
{/if}
