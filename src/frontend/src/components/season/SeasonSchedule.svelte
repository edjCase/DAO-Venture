<script lang="ts">
  import { SeasonStatus } from "../../ic-agent/declarations/league";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import MatchGroupCarosel from "../match/MatchGroupCarosel.svelte";
  import SeasonScheduleOverview from "./SeasonScheduleOverview.svelte";

  let seasonStatus: SeasonStatus | undefined;

  scheduleStore.subscribeStatus((status) => {
    seasonStatus = status;
  });
</script>

<div class="mx-auto lg:max-w-2xl xl:max-w-3xl">
  <SeasonScheduleOverview />

  {#if !!seasonStatus}
    <div class="text-center text-3xl font-bold my-4">
      {#if "notStarted" in seasonStatus}
        Season Not Started
      {:else if "completed" in seasonStatus}
        Season Complete
      {:else}
        Season InProgress
      {/if}
    </div>
  {/if}
  <MatchGroupCarosel />
</div>
