<script lang="ts">
  import { scheduleStore } from "../../stores/ScheduleStore";
  import SeasonScheduleOverview from "./SeasonScheduleOverview.svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import MatchSchedule from "./MatchSchedule.svelte";
  import { teamStore } from "../../stores/TeamStore";
  import { TeamOrUndetermined } from "../../models/Team";
  import {
    InProgressSeasonMatchGroupVariant,
    Team,
    TeamAssignment,
  } from "../../ic-agent/declarations/main";

  type MatchGroup = {
    time: bigint;
    matches: Match[];
  };
  type Match = {
    team1: TeamOrUndetermined;
    team2: TeamOrUndetermined;
  };

  $: teams = $teamStore;
  let matchGroupVariants: InProgressSeasonMatchGroupVariant[] = [];
  let matchGroups: MatchGroup[] | undefined;

  let mapTeamAssignment = (
    team: TeamAssignment,
    teams: Team[],
  ): TeamOrUndetermined => {
    if ("predetermined" in team) {
      return teams.find((t) => t.id == team.predetermined)!;
    }
    if ("winnerOfMatch" in team) {
      return {
        winnerOfMatch: Number(team.winnerOfMatch),
      };
    }
    return {
      seasonStandingIndex: Number(team.seasonStandingIndex),
    };
  };

  scheduleStore.subscribeMatchGroups((groups) => {
    matchGroupVariants = groups;
  });

  $: {
    if (teams && matchGroupVariants) {
      matchGroups = matchGroupVariants.map(
        (group: InProgressSeasonMatchGroupVariant): MatchGroup => {
          if ("completed" in group) {
            return {
              time: group.completed.time,
              matches: group.completed.matches.map((match) => {
                return {
                  team1: teams.find((t) => t.id == match.team1.id)!,
                  team2: teams.find((t) => t.id == match.team2.id)!,
                };
              }),
            };
          }
          if ("inProgress" in group) {
            return {
              time: group.inProgress.time,
              matches: group.inProgress.matches.map((match) => {
                return {
                  team1: teams.find((t) => t.id == match.team1.id)!,
                  team2: teams.find((t) => t.id == match.team2.id)!,
                };
              }),
            };
          }
          if ("scheduled" in group) {
            return {
              time: group.scheduled.time,
              matches: group.scheduled.matches.map((match) => {
                return {
                  team1: teams.find((t) => t.id == match.team1.id)!,
                  team2: teams.find((t) => t.id == match.team2.id)!,
                };
              }),
            };
          }
          return {
            time: group.notScheduled.time,
            matches: group.notScheduled.matches.map((match) => {
              return {
                team1: mapTeamAssignment(match.team1, teams),
                team2: mapTeamAssignment(match.team2, teams),
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
                {#if teams}
                  <MatchSchedule team1={match.team1} team2={match.team2} />
                {/if}
              </li>
            {/each}
          </ul>
        </div>
      {/each}
    </div>
  {/if}
</div>
