<script context="module" lang="ts">
</script>

<script lang="ts">
  import { matchGroupStore } from "../stores/MatchGroupStore";
  import VoteForMatchGroup from "../components/VoteForMatchGroup.svelte";
  import { onMount } from "svelte";
  import { MatchGroupDetails, mapMatchGroup } from "../models/Match";
  import MatchGroupCardGrid from "../components/MatchGroupCardGrid.svelte";

  export let matchGroupId: number;

  let matchGroup: MatchGroupDetails | undefined;

  matchGroupStore.subscribe((matchGroups) => {
    let g = matchGroups.find((item) => item.id == matchGroupId);
    if (g) {
      matchGroup = mapMatchGroup(g);
    } else {
      matchGroup = undefined;
    }
  });

  let remainingMillis: number | undefined;
  onMount(() => {
    const intervalId = setInterval(() => {
      if (matchGroup) {
        remainingMillis =
          Number(matchGroup.time / BigInt(1_000_000)) - Date.now();
        if (remainingMillis <= 0) {
          clearInterval(intervalId);
        }
      }
    }, 1000);

    return () => clearInterval(intervalId); // Cleanup interval on component destroy
  });
  let printTime = (remainingMillis: number): string => {
    if (remainingMillis < 1) {
      matchGroupStore.refetchById(matchGroupId);
      return "ANY SECOND!";
    }
    let seconds = Math.floor(remainingMillis / 1000);
    let minutes = Math.floor(seconds / 60);
    let hours = Math.floor(minutes / 60);
    let days = Math.floor(hours / 24);

    // Adjust values so they reflect remaining time, not total time
    seconds %= 60;
    minutes %= 60;
    hours %= 24;

    return `${days} days, ${hours} hours, ${minutes} minutes, ${seconds} seconds`;
  };
</script>

{#if !!matchGroup}
  <section>
    <section class="match-details">
      {#if remainingMillis && "notStarted" in matchGroup.state}
        <h1>
          Upcoming in {printTime(remainingMillis)}
        </h1>
      {/if}

      <MatchGroupCardGrid {matchGroup} />

      {#if "notStarted" in matchGroup.state}
        {#each matchGroup.matches as match}
          <div>
            <h1>Vote: {match.team1.name} vs {match.team2.name}</h1>
            <h1>{match.team1.name}</h1>
            <VoteForMatchGroup
              matchGroupId={matchGroup.id}
              teamId={match.team1.id}
            />
            <h1>{match.team2.name}</h1>
            <VoteForMatchGroup
              matchGroupId={matchGroup.id}
              teamId={match.team2.id}
            />
          </div>
        {/each}
      {:else if "completed" in matchGroup.state}
        <div>Completed</div>
      {:else}
        <h1>Game hasnt started</h1>
      {/if}
    </section>
  </section>
{:else}
  Loading...
{/if}

<style>
  section {
    margin-bottom: 20px;
  }
  .match-details {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
