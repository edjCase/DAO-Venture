<script lang="ts">
  import MatchCardGrid from "../components/MatchCardGrid.svelte";
  import { matchStore } from "../stores/MatchStore";
  import type { Match } from "../types/Match";

  let completedmatchStore: Match[];

  // Subscribe to the store
  matchStore.subscribe((matches) => {
    // Find the item with the specific id
    completedmatchStore = matches.filter((item) => item.end != null);
  });
</script>

<MatchCardGrid matches={completedmatchStore} />
