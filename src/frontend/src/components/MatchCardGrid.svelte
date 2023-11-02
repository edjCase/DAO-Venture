<script lang="ts">
  import type { Match } from "../ic-agent/Stadium";
  import { matchStore } from "../stores/MatchStore";
  import MatchCard from "./MatchCard.svelte";
  export let matchFilter: (match: Match) => boolean;

  let matches: Match[];
  matchStore.subscribe((newMatches) => {
    // Order by date
    matches = newMatches.filter(matchFilter).sort((a, b) => {
      if (a.time < b.time) return -1;
      if (a.time > b.time) return 1;
      return 0;
    });
  });
</script>

{#if matches === undefined}
  <div>Loading...</div>
{:else}
  <div class="match-card-grid">
    {#each matches as match}
      <MatchCard {match} />
    {/each}
  </div>

  <style>
    .match-card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, 400px);
      justify-content: center;
    }
  </style>
{/if}
