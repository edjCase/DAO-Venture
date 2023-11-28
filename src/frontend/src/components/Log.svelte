<script lang="ts">
  import type { LogEntry } from "../ic-agent/Stadium";

  export let log: LogEntry[];
</script>

<ul class="log">
  {#each [...log].reverse() as entry}
    <li>
      <pre>{entry.message}</pre>
    </li>
  {/each}
</ul>

<style>
  .log {
    max-width: 300px;
  }
  .important {
    text-decoration: underline;
  }
</style>
