<script lang="ts">
  import { Principal } from "@dfinity/principal";
  import {
    leagueAgentFactory,
    type DivisionScheduleRequest,
  } from "../ic-agent/League";
  import { divisionStore } from "../stores/DivisionStore";
  import { dateToNanoseconds } from "../utils/DateUtils";
  import { SeasonSchedule } from "../ic-agent/Stadium";
  import { onMount } from "svelte";

  let schedule: SeasonSchedule | undefined;
  $: divisions = $divisionStore;

  onMount(() => {
    leagueAgentFactory()
      .getSeasonSchedule()
      .then((result) => {
        if (result.length > 0) {
          schedule = result[0];
        } else {
          schedule = undefined;
        }
      });
  });

  let startTimes: Record<string, string> = {};
  let scheduleSeason = async () => {
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
          // matchGroupStore.refetchById(result.ok); TODO
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

{#if schedule}
  <p>Schedule:</p>
  {#each schedule.divisions as divisionSchedule}
    <div>
      {#each divisionSchedule.matchGroups as matchGroup, index}
        <div>Week {index + 1}</div>
        {#each matchGroup.matches as match}
          <div>
            {match.team1.name}
            vs
            {match.team2.name}
          </div>
        {/each}
      {/each}
    </div>
  {/each}
  <!-- <button on:click={closeSeason}>Close Season</button> -->
{:else if divisions}
  {#each divisions as division}
    <span>
      <h2>Division: {division.name}</h2>
      <input
        type="datetime-local"
        on:change={(e) =>
          (startTimes[division.id.toString()] = e.currentTarget.value)}
      />
    </span>
  {/each}
  <button on:click={scheduleSeason}>Schedule</button>
{/if}
