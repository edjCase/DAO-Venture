<script lang="ts">
  import {
    leagueAgentFactory,
    type DivisionScheduleRequest,
    type DivisionSchedule,
    type Team,
    type Stadium,
  } from "../ic-agent/League";
  import { divisionStore } from "../stores/DivisionStore";
  import { matchStore } from "../stores/MatchStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import { teamStore } from "../stores/TeamStore";
  import { dateToNanoseconds } from "../utils/DateUtils";

  let divisions;
  let stadiums;

  let mapSchedule = (
    schedule: DivisionSchedule,
    teams: Team[],
    stadiums: Stadium[]
  ) => {
    let weeks = schedule.weeks.map((s) => ({
      ...s,
      matchUps: s.matchUps.map((m) => ({
        ...m,
        team1Name:
          teams.find((t) => t.id.compareTo(m.team1) == "eq")?.name ?? "",
        team2Name:
          teams.find((t) => t.id.compareTo(m.team2) == "eq")?.name ?? "",
        stadiumName:
          stadiums.find((s) => s.id.compareTo(m.stadiumId) == "eq")?.name ?? "",
      })),
    }));
    return {
      ...schedule,
      weeks: weeks,
    };
  };
  let mapDivisions = (divisions, teams, stadiums) => {
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
  stadiumStore.subscribe((newStadiums) => {
    divisions = mapDivisions($divisionStore, $teamStore, newStadiums);
  });

  let startTimes: Record<string, string> = {};
  let schedule = async () => {
    let divisionSchedules: DivisionScheduleRequest[] = Object.keys(
      startTimes
    ).map((id) => ({
      id: parseInt(id),
      start: dateToNanoseconds(new Date(startTimes[id])),
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
          matchStore.refetch();
        } else {
          console.log("Failed to schedule season", result);
        }
      });
  };
</script>

{#if divisions && divisions.length > 0}
  {#each divisions as division}
    <span>
      <h2>Division: {division.name}</h2>
      {#if !division.schedule}
        <input
          type="datetime-local"
          on:change={(e) => (startTimes[division.id] = e.currentTarget.value)}
        />
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
                      Failed to schedule. Error: {JSON.stringify(
                        matchUp.status.failedToSchedule
                      )}
                    {/if}
                  </div>
                </div>
              </div>
            {/each}
          </div>
        {/each}
      {/if}
    </span>
  {/each}
  <button on:click={schedule}>Schedule</button>
{/if}
