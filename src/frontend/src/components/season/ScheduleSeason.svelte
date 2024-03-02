<script lang="ts">
  import { Button, Input } from "flowbite-svelte";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import { dateToNanoseconds } from "../../utils/DateUtils";
  import { leagueAgentFactory } from "../../ic-agent/League";
  import { SeasonStatus } from "../../ic-agent/declarations/league";
  import { scenarios } from "../../data/ScenarioData";

  let startTime: bigint | undefined;
  let scheduleSeason = async () => {
    if (!startTime) {
      return;
    }
    console.log("Scheduling season", startTime);
    leagueAgentFactory()
      .startSeason({
        startTime: startTime,
        scenarios: scenarios,
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
  let closeSeason = async () => {
    leagueAgentFactory()
      .closeSeason()
      .then((result) => {
        if ("ok" in result) {
          console.log("Closed season");
          scheduleStore.refetch();
        } else {
          console.log("Failed to close season", result);
        }
      });
  };
  let setStartTime = (e: any) => {
    if (!e.currentTarget) {
      return;
    }
    startTime = dateToNanoseconds(new Date(e.currentTarget.value));
  };

  let scheduleStatus: SeasonStatus | undefined;
  scheduleStore.subscribeStatus((value) => {
    scheduleStatus = value;
  });
</script>

<div class="container">
  <Input type="datetime-local" on:change={setStartTime} />
  <Button on:click={scheduleSeason}>Schedule Season</Button>
  {#if scheduleStatus && ("inProgress" in scheduleStatus || "starting" in scheduleStatus)}
    <Button on:click={closeSeason}>Close Season</Button>
  {/if}
</div>

<style>
  .container {
    width: 200px;
  }
</style>
