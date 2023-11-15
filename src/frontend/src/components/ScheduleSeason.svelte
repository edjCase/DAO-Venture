<script lang="ts">
  import { SeasonStatus, leagueAgentFactory } from "../ic-agent/League";
  import { dateToNanoseconds } from "../utils/DateUtils";
  import { seasonStatusStore } from "../stores/ScheduleStore";

  let seasonStatus: SeasonStatus | undefined;

  seasonStatusStore.subscribe((s) => {
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
          seasonStatusStore.refetch();
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
