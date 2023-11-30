<script lang="ts" context="module">
  export type MatchGroupVariant =
    | { completed: CompletedMatchGroup }
    | { live: InProgressMatchGroup }
    | { next: ScheduledMatchGroup }
    | { upcoming: NotScheduledMatchGroup };
</script>

<script lang="ts">
  import {
    CompletedMatchGroup,
    InProgressMatchGroup,
    NotScheduledMatchGroup,
    ScheduledMatchGroup,
  } from "../models/Season";
  import MatchCard, { MatchVariant } from "./MatchCard.svelte";

  export let matchGroup: MatchGroupVariant;

  let matches: MatchVariant[];
  if ("live" in matchGroup) {
    matches = matchGroup.live.matches.map((m) => ({ live: m }));
  } else if ("next" in matchGroup) {
    matches = matchGroup.next.matches.map((m) => ({ next: m }));
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
