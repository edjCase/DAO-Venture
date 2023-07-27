<script lang="ts">
    import type { Game, Team } from "../types/Game";
    import ScoreHeaderScore from "./ScoreHeaderScore.svelte";
    import ScoreHeaderTeam from "./ScoreHeaderTeam.svelte";

    export let game: Game;

    let playerChosenTeam = 1;

    let totalVotes = game.team1.votes + game.team2.votes;
</script>

<div class="score-header">
    <ScoreHeaderTeam team={game.team1} />
    <ScoreHeaderScore
        won={game.winningTeamId == game.team1.id}
        playerChoice={game.team1.id == playerChosenTeam}
        score={game.team1.gameStats?.score}
        predictionPercent={game.team1.votes / totalVotes}
    />
    <div>
        <div class="state">{game.end == null ? "Not Final" : "Final"}</div>
        <div class="end-date">{game.end?.toDateString()}</div>
    </div>
    <ScoreHeaderScore
        won={game.winningTeamId == game.team2.id}
        playerChoice={game.team2.id == playerChosenTeam}
        score={game.team2.gameStats?.score}
        predictionPercent={game.team2.votes / totalVotes}
    />
    <ScoreHeaderTeam team={game.team2} />
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
