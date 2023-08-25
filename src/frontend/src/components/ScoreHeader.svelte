<script lang="ts">
  import type { Match } from "../ic-agent/Stadium";
  import ScoreHeaderScore from "./ScoreHeaderScore.svelte";
  import ScoreHeaderTeam from "./ScoreHeaderTeam.svelte";

  export let match: Match;

  let team1 = match.teams[0];
  let team2 = match.teams[1];
  let winningTeam;
  if (match.winner.length == 0) {
    winningTeam = null;
  } else if (match.winner[0] == team1.id) {
    winningTeam = team1;
  } else if (match.winner[0] == team2.id) {
    winningTeam = team2;
  } else {
    throw new Error("Invalid winner");
  }
  let playerChosenTeamId;
  if (team1.predictionVotes > team2.predictionVotes) {
    playerChosenTeamId = team1.id;
  } else if (team1.predictionVotes < team2.predictionVotes) {
    playerChosenTeamId = team2.id;
  }

  let totalVotes = team1.predictionVotes + team2.predictionVotes;
  let team1Percent;
  let team2Percent;
  if (totalVotes < 1) {
    team1Percent = 0;
    team2Percent = 0;
  } else {
    team1Percent = team1.predictionVotes / totalVotes;
    team2Percent = team1.predictionVotes / totalVotes;
  }
</script>

<div class="score-header">
  <ScoreHeaderTeam team={team1} />
  <ScoreHeaderScore
    won={winningTeam?.id == team1.id}
    playerChoice={team1.id == playerChosenTeamId}
    score={team1.score.length > 0 ? team1.score[0] : null}
    predictionPercent={team1Percent}
  />
  <div>
    <div class="state">
      {match.winner.length < 1 ? "Not Final" : "Winner :" + winningTeam?.name}
    </div>
  </div>
  <ScoreHeaderScore
    won={winningTeam?.id == team2.id}
    playerChoice={team2.id == playerChosenTeamId}
    score={team2.score.length > 0 ? team2.score[0] : null}
    predictionPercent={team2Percent}
  />
  <ScoreHeaderTeam team={team2} />
</div>

<style>
  .state {
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
