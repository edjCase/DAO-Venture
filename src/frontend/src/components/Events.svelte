<script lang="ts">
  import type { MatchEvent } from "../ic-agent/Stadium";

  export let events: MatchEvent[];
</script>

<ul>
  {#each [...events].reverse() as event}
    <li>{event.description}</li>
  {/each}
</ul>
