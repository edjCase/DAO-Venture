<script lang="ts">
  import {
    leagueAgentFactory,
    type DivisionScheduleRequest,
  } from "../ic-agent/League";
  import { divisionStore } from "../stores/DivisionStore";
  import { dateToNanoseconds } from "../utils/DateUtils";

  $: divisions = $divisionStore;

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
      {#if division.schedule.length == 0}
        <input
          type="datetime-local"
          on:change={(e) => (startTimes[division.id] = e.currentTarget.value)}
        />
      {:else}
        <p>Schedule:</p>
        {#each division.schedule[0].weeks as week, index}
          <div>
            <div>Week {index + 1}</div>
            {#each week.matchUps as matchUp}
              <div>
                {matchUp.team1} vs {matchUp.team2} at {matchUp.stadiumId}
                <div>
                  Status:
                  {#if "scheduled" in matchUp.status}
                    Scheduled. MatchId: {matchUp.status.scheduled}
                  {:else}
                    Failed to schedule. Error: {JSON.stringify(
                      matchUp.status.failedToSchedule
                    )}
                  {/if}
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
