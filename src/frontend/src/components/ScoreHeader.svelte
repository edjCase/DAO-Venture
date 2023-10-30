<script lang="ts">
  import type { Principal } from "@dfinity/principal";
  import ScoreHeaderScore from "./ScoreHeaderScore.svelte";
  import ScoreHeaderTeam from "./ScoreHeaderTeam.svelte";

  type Team = {
    id: Principal;
    name: string;
    predictionVotes: bigint;
    score: bigint;
  };

  export let team1: Team;
  export let team2: Team;
  export let winner: undefined | Principal;

  let winningTeam: Team | undefined;
  if (!winner) {
    winningTeam = undefined;
  } else if (winner == team1.id) {
    winningTeam = team1;
  } else if (winner == team2.id) {
    winningTeam = team2;
  } else {
    throw new Error("Invalid winner: " + winner);
  }
  let playerChosenTeamId: Principal | undefined;
  if (team1.predictionVotes > team2.predictionVotes) {
    playerChosenTeamId = team1.id;
  } else if (team1.predictionVotes < team2.predictionVotes) {
    playerChosenTeamId = team2.id;
  }

  let totalVotes = team1.predictionVotes + team2.predictionVotes;
  let team1Percent: bigint;
  let team2Percent: bigint;
  if (totalVotes < 1) {
    team1Percent = BigInt(0);
    team2Percent = BigInt(0);
  } else {
    team1Percent = team1.predictionVotes / totalVotes;
    team2Percent = team1.predictionVotes / totalVotes;
  }
</script>

<div class="score-header">
  <ScoreHeaderTeam teamId={team1.id} />
  <ScoreHeaderScore
    won={winningTeam?.id == team1.id}
    playerChoice={team1.id == playerChosenTeamId}
    score={team1.score}
    predictionPercent={team1Percent}
  />
  <div>
    <div class="state">
      {!winner ? "Not Final" : "Winner :" + winningTeam?.name}
    </div>
  </div>
  <ScoreHeaderScore
    won={winningTeam?.id == team2.id}
    playerChoice={team2.id == playerChosenTeamId}
    score={team2.score}
    predictionPercent={team2Percent}
  />
  <ScoreHeaderTeam teamId={team2.id} />
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
