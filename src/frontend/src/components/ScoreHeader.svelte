<script lang="ts">
  import type { Match, Team } from "../types/Match";
  import ScoreHeaderScore from "./ScoreHeaderScore.svelte";
  import ScoreHeaderTeam from "./ScoreHeaderTeam.svelte";

  export let match: Match;

  let playerChosenTeam = 1;

  let totalVotes = match.team1.votes + match.team2.votes;
</script>

<div class="score-header">
  <ScoreHeaderTeam team={match.team1} />
  <ScoreHeaderScore
    won={match.winningTeamId == match.team1.id}
    playerChoice={match.team1.id == playerChosenTeam}
    score={match.team1.matchStats?.score}
    predictionPercent={match.team1.votes / totalVotes}
  />
  <div>
    <div class="state">{match.end == null ? "Not Final" : "Final"}</div>
    <div class="end-date">{match.end?.toDateString()}</div>
  </div>
  <ScoreHeaderScore
    won={match.winningTeamId == match.team2.id}
    playerChoice={match.team2.id == playerChosenTeam}
    score={match.team2.matchStats?.score}
    predictionPercent={match.team2.votes / totalVotes}
  />
  <ScoreHeaderTeam team={match.team2} />
</div>

<style>
  .state {
    text-align: center;
  }
  .end-date {
    text-align: center;
  }
  .score-header {
    display: flex;
    justify-content: space-around;
    align-items: center;
    padding: 20px;
    margin: 20px 240px;
    border: 1px solid var(--color-secondary);
  }
</style>
