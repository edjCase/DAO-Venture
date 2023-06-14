<script lang="ts">
  import GameCardGrid from "../components/GameCardGrid.svelte";
  import News from "../components/News.svelte";
  import { completedGamesStore, upcomingGamesStore } from "../stores/game-store";

</script>

<div class="latest-games">
  <h2>Latest Games</h2>
  <GameCardGrid games={$completedGamesStore} />
</div>

<div class="upcoming-games">
  <h2>Upcoming Games</h2>
  <GameCardGrid games={$upcomingGamesStore} />
</div>

<div class="news">
  <h2>News</h2>
  <News />
</div>

<div />

<style>
</style>
