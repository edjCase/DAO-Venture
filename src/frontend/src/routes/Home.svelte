<script lang="ts">
  import MatchCardGrid from "../components/MatchCardGrid.svelte";
  import { matchStore } from "../stores/MatchStore";
  import type { Match } from "../types/Match";

  let completedmatchStore: Match[];
  let upcomingmatchStore: Match[];

  // Subscribe to the store
  matchStore.subscribe((matches) => {
    // Find the item with the specific id
    completedmatchStore = matches.filter((item) => item.end != null);
    upcomingmatchStore = matches.filter((item) => item.end == null);
  });
</script>

<div class="latest-matches">
  <h1>Latest Matches</h1>
  <MatchCardGrid matches={completedmatchStore} />
</div>

<div class="upcoming-matches">
  <h1>Upcoming Matches</h1>
  <MatchCardGrid matches={upcomingmatchStore} />
</div>

<div />

<style>
  .latest-matches {
    margin-bottom: 50px;
    text-align: center;
  }
  .upcoming-matches {
    margin-bottom: 50px;
    text-align: center;
  }
</style>
