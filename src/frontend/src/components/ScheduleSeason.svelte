<script lang="ts">
  import {
    leagueAgentFactory,
    type DivisionScheduleRequest,
  } from "../ic-agent/League";
  import { divisionStore } from "../stores/DivisionStore";
  import { dateToNanoseconds } from "../utils/DateUtils";
  import { SeasonSchedule } from "../ic-agent/League";
  import { onMount } from "svelte";
  import { matchGroupStore } from "../stores/MatchGroupStore";

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
      id: Number(id),
      startTime: dateToNanoseconds(new Date(startTimes[id])),
    }));
    if (divisionSchedules.length < 1) {
      console.log("No divisions specified to schedule");
      return;
    }
    console.log("Scheduling season", divisionSchedules);
    leagueAgentFactory()
      .startSeason({
        divisions: divisionSchedules,
      })
      .then((result) => {
        if ("ok" in result) {
          console.log("Scheduled season");
          divisionStore.refetch();
          matchGroupStore.refetchAll();
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
  <!-- <button  class="button-style" on:click={closeSeason}>Close Season</button> -->
{:else if divisions}
  <div class="divisions">
    {#each divisions as division}
      <span class="division">
        <h2>Division: {division.name}</h2>
        <input
          type="datetime-local"
          on:change={(e) =>
            (startTimes[division.id.toString()] = e.currentTarget.value)}
        />
      </span>
    {/each}
  </div>
  <button class="button-style" on:click={scheduleSeason}>Schedule</button>
{/if}

<style>
  .divisions {
    display: flex;
    flex-direction: row;
  }
  .division {
    margin: 20px;
  }
</style>
