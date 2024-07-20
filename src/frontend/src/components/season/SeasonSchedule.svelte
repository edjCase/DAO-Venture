<script lang="ts">
  import { scheduleStore } from "../../stores/ScheduleStore";
  import SeasonScheduleOverview from "./SeasonScheduleOverview.svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import MatchSchedule from "./MatchSchedule.svelte";
  import { townStore } from "../../stores/TownStore";
  import { TownOrUndetermined } from "../../models/Town";
  import {
    InProgressSeasonMatchGroupVariant,
    Town,
    TownAssignment,
  } from "../../ic-agent/declarations/main";

  type MatchGroup = {
    time: bigint;
    matches: Match[];
  };
  type Match = {
    town1: TownOrUndetermined;
    town2: TownOrUndetermined;
  };

  $: towns = $townStore;
  let matchGroupVariants: InProgressSeasonMatchGroupVariant[] = [];
  let matchGroups: MatchGroup[] | undefined;

  let mapTownAssignment = (
    town: TownAssignment,
    towns: Town[],
  ): TownOrUndetermined => {
    if ("predetermined" in town) {
      return towns.find((t) => t.id == town.predetermined)!;
    }
    if ("winnerOfMatch" in town) {
      return {
        winnerOfMatch: Number(town.winnerOfMatch),
      };
    }
    return {
      seasonStandingIndex: Number(town.seasonStandingIndex),
    };
  };

  scheduleStore.subscribeMatchGroups((groups) => {
    matchGroupVariants = groups;
  });

  $: {
    if (towns && matchGroupVariants) {
      matchGroups = matchGroupVariants.map(
        (group: InProgressSeasonMatchGroupVariant): MatchGroup => {
          if ("completed" in group) {
            return {
              time: group.completed.time,
              matches: group.completed.matches.map((match) => {
                return {
                  town1: towns.find((t) => t.id == match.town1.id)!,
                  town2: towns.find((t) => t.id == match.town2.id)!,
                };
              }),
            };
          }
          if ("inProgress" in group) {
            return {
              time: group.inProgress.time,
              matches: group.inProgress.matches.map((match) => {
                return {
                  town1: towns.find((t) => t.id == match.town1.id)!,
                  town2: towns.find((t) => t.id == match.town2.id)!,
                };
              }),
            };
          }
          if ("scheduled" in group) {
            return {
              time: group.scheduled.time,
              matches: group.scheduled.matches.map((match) => {
                return {
                  town1: towns.find((t) => t.id == match.town1.id)!,
                  town2: towns.find((t) => t.id == match.town2.id)!,
                };
              }),
            };
          }
          return {
            time: group.notScheduled.time,
            matches: group.notScheduled.matches.map((match) => {
              return {
                town1: mapTownAssignment(match.town1, towns),
                town2: mapTownAssignment(match.town2, towns),
              };
            }),
          };
        },
      );
    }
  }
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
                {#if towns}
                  <MatchSchedule town1={match.town1} town2={match.town2} />
                {/if}
              </li>
            {/each}
          </ul>
        </div>
      {/each}
    </div>
  {/if}
</div>
