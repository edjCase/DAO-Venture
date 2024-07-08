<script lang="ts">
  import { scheduleStore } from "../../stores/ScheduleStore";
  import SeasonScheduleOverview from "./SeasonScheduleOverview.svelte";
  import { MatchGroupDetails } from "../../models/Match";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import MatchSchedule from "./MatchSchedule.svelte";
  import { teamStore } from "../../stores/TeamStore";

  let matchGroups: MatchGroupDetails[] | undefined;
  scheduleStore.subscribeMatchGroups((groups) => {
    matchGroups = groups;
  });
  $: teams = $teamStore;
</script>

<div class="mx-auto lg:max-w-2xl xl:max-w-3xl">
  <SeasonScheduleOverview />
  {#if matchGroups}
    <div class="container mx-auto px-4 py-6">
      {#each matchGroups as group, index}
        <div class="mb-6" id="group-{index}">
          <h2 class="text-xl font-bold mb-2">Match Group {index + 1}</h2>
          <p class="text-gray-500 mb-4">
            {nanosecondsToDate(group.time).toLocaleString()}
          </p>
          <ul class="">
            {#each group.matches as match}
              <li class="py-3">
                {#if teams}
                  <MatchSchedule {match} {teams} />
                {/if}
              </li>
            {/each}
          </ul>
        </div>
      {/each}
    </div>
  {/if}
</div>
