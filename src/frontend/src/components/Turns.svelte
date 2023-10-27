<script lang="ts">
  import type { MatchTurn } from "../ic-agent/Stadium";
  import { toJsonString } from "../utils/JsonUtil";

  export let turns: MatchTurn[];
</script>

<ul>
  {#each [...turns].reverse() as turn}
    <li>
      <ul>
        {#each turn.events as event}
          <li><pre>{toJsonString(event, false)}</pre></li>
        {/each}
      </ul>
    </li>
  {/each}
</ul>
