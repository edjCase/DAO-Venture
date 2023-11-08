<script lang="ts">
  import { TeamIdOrTie } from "../ic-agent/Stadium";
  import { CompletedMatchStateDetails, MatchDetail } from "../models/Match";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetail;
  export let matchState: CompletedMatchStateDetails;

  let team1Score: bigint | undefined;
  let team2Score: bigint | undefined;
  let winner: TeamIdOrTie | undefined;
  if ("played" in matchState) {
    team1Score = matchState.played.team1.score;
    team2Score = matchState.played.team2.score;
    winner = matchState.played.winner;
  }
</script>

<div class="card">
  <MatchCardHeader {match} {team1Score} {team2Score} {winner} />
  <div class="mid" />
  <div class="footer" />
</div>

<style>
  .card {
    background: black;
    border-radius: 5px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
    margin: 1rem;
    width: 350px;
  }
  .card :global(a) {
    text-decoration: none;
    color: inherit;
  }

  .mid {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }
</style>
