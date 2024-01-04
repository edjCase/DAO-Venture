<script lang="ts">
  import { Button, Input } from "flowbite-svelte";
  import { leagueAgentFactory } from "../ic-agent/League";
  import { scheduleStore } from "../stores/ScheduleStore";
  import { dateToNanoseconds } from "../utils/DateUtils";

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
  let setStartTime = (e: any) => {
    if (!e.currentTarget) {
      return;
    }
    startTime = dateToNanoseconds(new Date(e.currentTarget.value));
  };
</script>

<div class="container">
  <Input type="datetime-local" on:change={setStartTime} />
  <Button on:click={scheduleSeason}>Schedule</Button>
</div>

<style>
  .container {
    width: 200px;
  }
</style>
