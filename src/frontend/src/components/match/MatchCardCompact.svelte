<script lang="ts">
  import { MatchDetails } from "../../models/Match";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetails;
</script>

<div class="card">
  <MatchCardHeader
    team1={match.team1}
    team2={match.team2}
    winner={match.winner}
  >
    {#if match.state == "InProgress"}
      <div>LIVE!</div>
    {:else if match.state == "Played"}
      {#if !match.winner}
        <div>Bad state</div>
      {:else if "team1" in match.winner}
        {match.team1?.name} Win!
      {:else if "team2" in match.winner}
        {match.team2?.name} Win!
      {:else}
        Its a tie!
      {/if}
    {:else if match.state == "Error"}
      <div>Bad state:</div>
    {/if}
  </MatchCardHeader>
</div>

<style>
  /* Card styles for matches */
  .card {
    background-color: var(--color-bg-dark);
    color: var(--color-text-light);
    padding: 0.5em;
    border: 1px solid var(--color-border);
    border-radius: 8px;
    width: 100%;
  }

  .card:hover {
    border-color: var(--color-primary);
  }
</style>
