<script lang="ts">
  import { navigate } from "svelte-routing";
  import { nanosecondsToDate } from "../utils/DateUtils";
  import CompletedMatchCard from "./CompletedMatchCard.svelte";
  import NotStartedMatchCard from "./NotStartedMatchCard.svelte";
  import InProgressMatchCard from "./InProgressMatchCard.svelte";
  import { MatchGroupSchedule } from "../ic-agent/League";

  export let matchGroup: MatchGroupSchedule;
</script>

<div
  class="match-group"
  on:click={() => navigate("/match-groups/" + matchGroup.id)}
  on:keydown={() => {}}
  on:keyup={() => {}}
  role="link"
  tabindex="0"
>
  {#if "notStarted" in matchGroup.state}
    <div class="not-started">
      <div>
        {nanosecondsToDate(matchGroup.time).toLocaleString()}
      </div>
      {#each matchGroup.matches as match}
        <NotStartedMatchCard {match} compact={true} />
      {/each}
    </div>
  {:else if "completed" in matchGroup.state}
    <div>Completed Match Group</div>
    {#each matchGroup.state.completed.matches as match, index}
      <div class="completed">
        <CompletedMatchCard
          matchState={match}
          match={matchGroup.matches[index]}
          compact={true}
        />
      </div>
    {/each}
  {:else}
    <div class="match-group in-progress">
      {#if "inProgress" in matchGroup.state}
        <div>Live Now!</div>
        {#each matchGroup.state.inProgress.matches as match, index}
          {#if "inProgress" in match}
            <InProgressMatchCard
              matchState={match.inProgress}
              match={matchGroup.matches[index]}
              compact={true}
            />
          {:else if "completed" in match}
            <CompletedMatchCard
              matchState={match.completed}
              match={matchGroup.matches[index]}
              compact={true}
            />
          {/if}
        {/each}
      {/if}
    </div>
  {/if}
</div>

<style>
  .match-group {
    width: 400px;
    background-color: var(--color-bg-dark);
    border: 1px solid var(--color-border);
    padding: 1em;
    margin-bottom: 1em;
    border-radius: 5px;
  }
  .match-group:hover {
    cursor: pointer;
  }
  .match-group .completed {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .match-group .in-progress {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .match-group .not-started {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
