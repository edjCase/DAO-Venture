<script lang="ts">
  import VoteForMatchGroup from "../components/VoteForMatchGroup.svelte";
  import MatchGroupCardGrid from "../components/MatchGroupCardGrid.svelte";
  import { navigate } from "svelte-routing";
  import { scheduleStore } from "../stores/ScheduleStore";
  import { MatchGroupDetails } from "../models/Match";
  import { nanosecondsToDate } from "../utils/DateUtils";

  export let matchGroupIdString: string;

  let matchGroupId = Number(matchGroupIdString);
  if (isNaN(matchGroupId)) {
    // Handle the error, such as redirecting to an error page or showing a message
    navigate("/404", { replace: true });
  }

  let matchGroup: MatchGroupDetails | undefined;

  scheduleStore.subscribeMatchGroups(
    (seasonMatchGroups: MatchGroupDetails[]) => {
      matchGroup = seasonMatchGroups[matchGroupId];
    }
  );
</script>

{#if !!matchGroup}
  <section>
    <section class="match-details">
      {#if matchGroup.state == "Scheduled" || matchGroup.state == "NotScheduled"}
        <h1>
          Start Time: {nanosecondsToDate(matchGroup.time).toLocaleString()}
        </h1>
      {:else if matchGroup.state == "Completed"}
        <div>Match Group is over</div>
      {:else if matchGroup.state == "InProgress"}
        <div>Match Group is LIVE!</div>
      {/if}

      <MatchGroupCardGrid {matchGroup} />

      {#if matchGroup.state == "Scheduled"}
        {#each matchGroup.matches as match}
          <h1>Vote: {match.team1.name} vs {match.team2.name}</h1>
          <div class="match-vote">
            <div class="team-vote">
              <h1>{match.team1.name}</h1>
              <VoteForMatchGroup {matchGroupId} teamId={match.team1.id} />
            </div>
            <div class="team-vote">
              <h1>{match.team2.name}</h1>
              <VoteForMatchGroup {matchGroupId} teamId={match.team2.id} />
            </div>
          </div>
        {/each}
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
  .match-vote {
    display: flex;
    flex-direction: row;
    align-items: center;
  }
  .team-vote {
    margin: 20px;
  }
</style>
