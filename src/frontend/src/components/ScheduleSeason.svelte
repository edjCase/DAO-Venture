<script lang="ts">
  import { leagueAgentFactory } from "../ic-agent/League";
  import { dateToNanoseconds } from "../utils/DateUtils";
  import { SeasonSchedule } from "../ic-agent/League";
  import { seasonScheduleStore } from "../stores/ScheduleStore";

  let schedule: SeasonSchedule | undefined;

  seasonScheduleStore.subscribe((s) => {
    schedule = s;
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
          seasonScheduleStore.refetch();
        } else {
          console.log("Failed to schedule season", result);
        }
      });
  };
</script>

{#if schedule}
  <!-- <button  class="button-style" on:click={closeSeason}>Close Season</button> -->
{:else}
  <input
    type="datetime-local"
    on:change={(e) =>
      (startTime = dateToNanoseconds(new Date(e.currentTarget.value)))}
  />
  <button class="button-style" on:click={scheduleSeason}>Schedule</button>
{/if}
