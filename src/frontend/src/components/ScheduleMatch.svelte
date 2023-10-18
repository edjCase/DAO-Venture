<script lang="ts">
  import type { Principal } from "@dfinity/principal";
  import { teamStore } from "../stores/TeamStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import { leagueAgentFactory } from "../ic-agent/League";
  import { dateToNanoseconds } from "../utils/DateUtils";

  $: teams = $teamStore;
  $: stadiums = $stadiumStore;

  let stadium: Principal;
  let team1: Principal;
  let team2: Principal;
  let date: string;
  let scheduleMatch = function () {
    let time = dateToNanoseconds(new Date(date));
    leagueAgentFactory()
      .scheduleMatch(stadium, [team1, team2], time)
      .then((result) => {
        console.log("Scheduled match success: ", result);
        stadiumStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to schedule match: ", err);
      });
  };
</script>

<div>
  <label for="stadium">Stadium</label>
  <select id="stadium" bind:value={stadium}>
    {#each stadiums as stadium (stadium.id)}
      <option value={stadium.id}>{stadium.name}</option>
    {/each}
  </select>
</div>
<div>
  <label for="team1">Team 1</label>
  <select id="team1" bind:value={team1}>
    {#each teams as team (team.id)}
      <option value={team.id}>{team.name}</option>
    {/each}
  </select>
</div>
<div>
  <label for="team2">Team 2</label>
  <select id="team2" bind:value={team2}>
    {#each teams as team (team.id)}
      <option value={team.id}>{team.name}</option>
    {/each}
  </select>
</div>
<div>
  <label for="date">Date</label>
  <input type="datetime-local" id="date" bind:value={date} />
</div>
<button on:click={scheduleMatch}>Schedule Match</button>
