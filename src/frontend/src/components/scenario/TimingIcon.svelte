<script lang="ts">
  import { ActionTimingKind } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import GameIcon from "../game/GameIcon.svelte";
  export let value: ActionTimingKind;
</script>

<span>
  {#if "immediate" in value}
    <!-- No Icon -->
  {:else if "periodic" in value}
    <GameIcon value="periodic" />
    {#if "start" in value.periodic.phase}
      ☀️
    {:else if "end" in value.periodic.phase}
      🌑
    {:else}
      NOT IMPLEMENTED PERIODIC PHASE {toJsonString(value.periodic.phase)}
    {/if}
  {:else}
    NOT IMPLEMENTED TIMING {toJsonString(value)}
  {/if}
</span>
