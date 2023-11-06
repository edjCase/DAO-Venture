<script lang="ts">
  import { Principal } from "@dfinity/principal";
  import {
    leagueAgentFactory,
    type DivisionScheduleRequest,
    type Team,
    type Stadium,
    type Division,
  } from "../ic-agent/League";
  import { divisionStore } from "../stores/DivisionStore";
  import { matchGroupStore } from "../stores/MatchGroupStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import { teamStore } from "../stores/TeamStore";
  import { dateToNanoseconds } from "../utils/DateUtils";
  import { toJsonString } from "../utils/JsonUtil";

  type DivisionDetails = Omit<Division, "schedule"> & {
    schedule: ScheduleWithWeeks | null;
  };
  type MatchUpDetails = MatchUp & {
    team1Name: string;
    team2Name: string;
  };
  type SeasonWeekDetails = Omit<SeasonWeek, "matchUps"> & {
    matchUps: MatchUpDetails[];
  };
  type ScheduleWithWeeks = Omit<DivisionSchedule, "weeks"> & {
    weeks: SeasonWeekDetails[];
  };

  let divisions: DivisionDetails[] | undefined;

  let mapSchedule = (
    schedule: DivisionSchedule,
    teams: Team[]
  ): ScheduleWithWeeks => {
    let weeks = schedule.weeks.map((s) => ({
      ...s,
      matchUps: s.matchUps.map((m) => ({
        ...m,
        team1Name:
          teams.find((t) => t.id.compareTo(m.team1) == "eq")?.name ??
          "Unknown Team",
        team2Name:
          teams.find((t) => t.id.compareTo(m.team2) == "eq")?.name ??
          "Unknown Team",
      })),
    }));
    return {
      ...schedule,
      weeks: weeks,
    };
  };
  let mapDivisions = (
    divisions: Division[],
    teams: Team[],
    stadiums: Stadium[]
  ): DivisionDetails[] => {
    return divisions.map((d) => ({
      ...d,
      schedule:
        d.schedule.length == 0
          ? null
          : mapSchedule(d.schedule[0], teams, stadiums),
    }));
  };
  // TODO is there a better way to have teams and division dependencies
  teamStore.subscribe((teams) => {
    if (!divisions) {
      return;
    }
    divisions = mapDivisions($divisionStore, teams, $stadiumStore);
  });

  divisionStore.subscribe((newDivisions) => {
    divisions = mapDivisions(newDivisions, $teamStore, $stadiumStore);
  });

  let startTimes: Record<string, string> = {};
  let schedule = async () => {
    let divisionSchedules: DivisionScheduleRequest[] = Object.keys(
      startTimes
    ).map((id) => ({
      id: Principal.fromText(id),
      startTime: dateToNanoseconds(new Date(startTimes[id])),
    }));
    if (divisionSchedules.length < 1) {
      console.log("No divisions specified to schedule");
      return;
    }
    console.log("Scheduling season", divisionSchedules);
    leagueAgentFactory()
      .scheduleSeason({
        divisions: divisionSchedules,
      })
      .then((result) => {
        if ("ok" in result) {
          console.log("Scheduled season");
          divisionStore.refetch();
          matchGroupStore.refetchById(result.ok);
        } else {
          console.log("Failed to schedule season", result);
        }
      });
  };
  // let closeSeason = async () => {
  //   leagueAgentFactory()
  //     .closeSeason()
  //     .then((result) => {
  //       if ("ok" in result) {
  //         console.log("Closed season");
  //         divisionStore.refetch();
  //         matchStore.refetch();
  //       } else {
  //         console.log("Failed to close season", result);
  //       }
  //     });
  // };
</script>

@@ -1,168 +0,0 @@
{#if divisions && divisions.length > 0}
  {#each divisions as division}
    <span>
      <h2>Division: {division.name}</h2>
      {#if !division.schedule}
        <input
          type="datetime-local"
          on:change={(e) =>
            (startTimes[division.id.toString()] = e.currentTarget.value)}
        />
        <button on:click={schedule}>Schedule</button>
      {:else}
        <p>Schedule:</p>
        {#each division.schedule.weeks as week, index}
          <div>
            <div>Week {index + 1}</div>
            {#each week.matchUps as matchUp}
              <div>
                {matchUp.team1Name}
                vs
                {matchUp.team2Name}
                <div>
                  Status:
                  <div>
                    {#if "scheduled" in matchUp.status}
                      Scheduled - MatchId: {matchUp.status.scheduled} - {matchUp.stadiumName}
                    {:else}
                      Failed to schedule. Error: {toJsonString(
                        matchUp.status.failedToSchedule
                      )}
                    {/if}
                  </div>
                </div>
              </div>
            {/each}
          </div>
        {/each}
        <!-- <button on:click={closeSeason}>Close Season</button> -->
      {/if}
    </span>
  {/each}
{/if}
