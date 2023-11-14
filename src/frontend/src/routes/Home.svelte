<script lang="ts">
  import { Record } from "@dfinity/candid/lib/cjs/idl";
  import AssignPlayerToTeam from "../components/AssignPlayerToTeam.svelte";
  import CreatePlayer from "../components/CreatePlayer.svelte";
  import CreateStadium from "../components/CreateStadium.svelte";
  import CreateTeam from "../components/CreateTeam.svelte";
  import ScheduleMatch from "../components/ScheduleSeason.svelte";
  import TempInitialize from "../components/TempInitialize.svelte";
  import { teamStore } from "../stores/TeamStore";
  import ScheduleSeason from "../components/ScheduleSeason.svelte";
  import TeamGrid from "../components/TeamGrid.svelte";
  import { TabItem, Tabs } from "flowbite-svelte";
  import DivisionSummaryCard from "../components/DivisionSummaryCard.svelte";
  import { divisionStore } from "../stores/DivisionStore";
  import { Division } from "../ic-agent/League";
  import { seasonScheduleStore } from "../stores/ScheduleStore";

  $: teams = $teamStore;
  $: seasonSchedule = $seasonScheduleStore;

  let divisions: Division[] = [];

  divisionStore.subscribe((d) => {
    divisions = d;
  });
  let getDivisionName = (id: number) => {
    let division = divisions.find((d) => d.id === id);
    if (!division) {
      return "Unknown";
    }
    return division.name;
  };
</script>

<div class="content">
  {#if teams.length === 0}
    <TempInitialize />
  {:else}
    <div>
      <h1>Teams</h1>
      <TeamGrid />
    </div>

    {#if !seasonSchedule}
      {#if divisions.length > 0}
        <div>
          <h1>Schedule Season</h1>
          <ScheduleSeason />
        </div>
      {/if}
    {:else}
      <Tabs style="pill">
        {#each seasonSchedule.divisions as division}
          <TabItem>
            <div slot="title">{getDivisionName(division.id)}</div>
            <DivisionSummaryCard {division} />
          </TabItem>
        {/each}
      </Tabs>
    {/if}
  {/if}
  <hr style="margin-top: 400px;" />

  <div>
    <h1>Schedule Match</h1>
    <ScheduleMatch />
  </div>
  <div>
    <h1>Create Team</h1>
    <CreateTeam />
  </div>
  <div>
    <h1>Create Stadium</h1>
    <CreateStadium />
  </div>
  <div>
    <h1>Create Player</h1>
    <CreatePlayer />
  </div>
  <div>
    <h1>Assign Player to Team</h1>
    <AssignPlayerToTeam />
  </div>
</div>
