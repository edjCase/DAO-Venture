<script lang="ts">
  import { TeamIdOrTie } from "../ic-agent/Stadium";
  import { CompletedMatchStateDetails, MatchDetail } from "../models/Match";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetail;
  export let matchState: CompletedMatchStateDetails;
  export let compact: boolean = false;

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
  <MatchCardHeader {match} {team1Score} {team2Score} {winner}>
    {#if "played" in matchState}
      {#if "team1" in matchState.played.winner}
        {match.team1.name} Win!
      {:else if "team2" in matchState.played.winner}
        {match.team2.name} Win!
      {:else}
        Its a tie!
      {/if}
    {:else if "allAbsent" in matchState}
      No one showed up
    {:else if "absentTeam" in matchState}
      Team {matchState.absentTeam.name} didn't show up, thus forfeit
    {:else if "stateBroken" in matchState}
      Broken: {matchState.stateBroken}
    {/if}
  </MatchCardHeader>
  {#if !compact}
    <div class="mid" />
    <div class="footer" />
  {/if}
</div>

<style>
  .card {
    border-radius: 5px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
    width: 100%;
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
