<script lang="ts">
  import GameCardGrid from "../components/GameCardGrid.svelte";
  import News from "../components/News.svelte";
  import type { Game, CompletedGame } from "../types/Game";

  let completedGames: CompletedGame[] = [
    {
      id: 1,
      team1: "T1",
      team2: "T2",
      stadium: "S1",
      team1Score: 3,
      team2Score: 7,
    },
    {
      id: 2,
      team1: "T2",
      team2: "T3",
      stadium: "S2",
      team1Score: 2,
      team2Score: 3,
    },
  ];
  let upcomingGames: Game[] = [
    {
      id: 3,
      team1: "T5",
      team2: "T6",
      stadium: "S1",
    },
    {
      id: 4,
      team1: "T7",
      team2: "T8",
      stadium: "S2",
    },
  ];
</script>

<div class="latest-games">
  <h2>Latest Games</h2>
  <GameCardGrid games={completedGames} />
</div>

<div class="upcoming-games">
  <h2>Upcoming Games</h2>
  <GameCardGrid games={upcomingGames} />
</div>

<div class="news">
  <h2>News</h2>
  <News />
</div>

<div />

<style>
</style>
