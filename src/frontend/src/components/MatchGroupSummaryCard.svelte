<script lang="ts">
  import { navigate } from "svelte-routing";
  import { nanosecondsToDate } from "../utils/DateUtils";
  import MatchCard from "./MatchCard.svelte";
  import { MatchGroupDetails } from "../models/Match";

  export let matchGroup: MatchGroupDetails;
</script>

<div
  class="match-group"
  on:click={() => navigate("/match-groups/" + matchGroup.id)}
  on:keydown={() => {}}
  on:keyup={() => {}}
  role="link"
  tabindex="0"
>
  {#if matchGroup.state == "Scheduled"}
    <div class="not-started">
      <div>
        {nanosecondsToDate(matchGroup.time).toLocaleString()}
      </div>
    </div>
  {:else if matchGroup.state == "Completed"}
    <div>Completed Match Group</div>
  {:else if matchGroup.state == "InProgress"}
    <div>Live Now!</div>
  {:else}
    <div>Not Scheduled Yet</div>
  {/if}
  <div class="match-group">
    {#each matchGroup.matches as match}
      <div class="match">
        <MatchCard {match} compact={true} />
      </div>
    {/each}
  </div>
</div>

<style>
  .match-group {
    max-width: 500px;
    background-color: var(--color-bg-dark);
    padding: 1em;
    margin-bottom: 1em;
    border-radius: 5px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
  }
  .match-group:hover {
    cursor: pointer;
  }
  .match {
    width: 100%;
    min-width: 300px;
  }
</style>
