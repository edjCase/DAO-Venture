<script lang="ts">
  import { scheduleStore } from "../../stores/ScheduleStore";
  import SeasonScheduleOverview from "./SeasonScheduleOverview.svelte";
  import TeamLogo from "../team/TeamLogo.svelte";
  import { MatchGroupDetails } from "../../models/Match";
  import { nanosecondsToDate } from "../../utils/DateUtils";

  let matchGroups: MatchGroupDetails[] | undefined;
  scheduleStore.subscribeMatchGroups((groups) => {
    matchGroups = groups;
  });
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
                <div class="flex items-center justify-center text-center">
                  <TeamLogo team={match.team1} size="xs" name="left" />
                  <span class="text-gray-500 mx-1">vs</span>
                  <TeamLogo team={match.team2} size="xs" name="right" />
                </div>
              </li>
            {/each}
          </ul>
        </div>
      {/each}
    </div>
  {/if}
</div>
