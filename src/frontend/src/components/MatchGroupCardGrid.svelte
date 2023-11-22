<script lang="ts">
  import {
    LiveMatch,
    MatchGroupVariant,
    MatchVariant,
  } from "../stores/ScheduleStore";
  import MatchCard from "./MatchCard.svelte";

  export let matchGroup: MatchGroupVariant;

  let matches: MatchVariant[];
  if ("live" in matchGroup) {
    matches = matchGroup.live.matches.map((m) => ({ live: m }));
  } else if ("completed" in matchGroup) {
    matches = matchGroup.completed.matches.map((m) => ({ completed: m }));
  } else {
    matches = matchGroup.upcoming.matches.map((m) => ({ upcoming: m }));
  }
</script>

<div class="match-card-grid">
  {#each matches as match}
    <MatchCard {match} />
  {/each}
</div>

<style>
  .match-card-grid {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-evenly;
  }
</style>
