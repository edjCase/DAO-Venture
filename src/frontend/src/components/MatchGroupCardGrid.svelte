<script lang="ts">
  import { MatchGroupDetails } from "../models/Match";
  import CompletedMatchCard from "./CompletedMatchCard.svelte";
  import InProgressMatchCard from "./InProgressMatchCard.svelte";
  import NotStartedMatchCard from "./NotStartedMatchCard.svelte";

  export let matchGroup: MatchGroupDetails;
</script>

<div class="match-card-grid">
  {#if "inProgress" in matchGroup.state}
    {#each matchGroup.state.inProgress.matches as matchState, index}
      {#if "completed" in matchState}
        <CompletedMatchCard
          matchState={matchState.completed}
          match={matchGroup.matches[index]}
        />
      {:else}
        <InProgressMatchCard
          matchState={matchState.inProgress}
          match={matchGroup.matches[index]}
        />
      {/if}
    {/each}
  {:else if "completed" in matchGroup.state}
    {#each matchGroup.state.completed.matches as matchState, index}
      <CompletedMatchCard {matchState} match={matchGroup.matches[index]} />
    {/each}
  {:else if "notStarted" in matchGroup.state}
    {#each matchGroup.matches as match}
      <NotStartedMatchCard {match} />
    {/each}
  {/if}
</div>

<style>
  .match-card-grid {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-evenly;
  }
</style>
