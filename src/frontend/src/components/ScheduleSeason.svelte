<script lang="ts">
  import { leagueAgentFactory } from "../ic-agent/League";
  import { SeasonStatus } from "../models/Season";
  import { scheduleStore } from "../stores/ScheduleStore";
  import { dateToNanoseconds } from "../utils/DateUtils";

  let seasonStatus: SeasonStatus | undefined;

  scheduleStore.subscribeStatus((s) => {
    seasonStatus = s;
  });

  let startTime: bigint | undefined;
  let scheduleSeason = async () => {
    if (!startTime) {
      return;
    }
    leagueAgentFactory()
      .startSeason({
        startTime: startTime,
      })
      .then((result) => {
        if ("ok" in result) {
          console.log("Scheduled season");
          scheduleStore.refetch();
        } else {
          console.log("Failed to schedule season", result);
        }
      });
  };
</script>

{#if seasonStatus}
  {#if "notStarted" in seasonStatus}
    <input
      type="datetime-local"
      on:change={(e) =>
        (startTime = dateToNanoseconds(new Date(e.currentTarget.value)))}
    />
    <button class="button-style" on:click={scheduleSeason}>Schedule</button>
  {/if}
{/if}
