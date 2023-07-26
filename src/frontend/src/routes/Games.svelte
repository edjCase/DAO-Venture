<script lang="ts">
  import GameCardGrid from "../components/GameCardGrid.svelte";
  import { gamesStore } from "../stores/game-store";
  import type { Game } from "../types/Game";

  let completedGamesStore: Game[];

  // Subscribe to the store
  gamesStore.subscribe((games) => {
    // Find the item with the specific id
    completedGamesStore = games.filter((item) => item.end != null);
  });
</script>

<GameCardGrid games={completedGamesStore} />
