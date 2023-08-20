<script lang="ts">
  import MatchCard from "./MatchCard.svelte";
  import type { Match } from "../types/Match";
  export let matches: Match[];
</script>

<div class="match-card-grid">
  {#each matches as match (match.id)}
    <MatchCard {match} />
  {/each}
</div>

<style>
  .match-card-grid {
    display: flex;
    flex-direction: row;
    justify-content: center;
  }
</style>
