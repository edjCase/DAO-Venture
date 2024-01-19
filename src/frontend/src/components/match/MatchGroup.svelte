<script lang="ts">
  import MatchGroupCardGrid from "../match/MatchGroupCardGrid.svelte";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import { MatchGroupDetails } from "../../models/Match";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import PredictMatchOutcome from "./PredictMatchOutcome.svelte";

  export let matchGroupId: number;

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
      {#if matchGroup.state == "Scheduled"}
        <h1>Predict the upcoming match-up winners</h1>
        {#each matchGroup.matches as match}
          <PredictMatchOutcome {match} />
        {/each}
      {:else}
        <MatchGroupCardGrid {matchGroup} />
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
