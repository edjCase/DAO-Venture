<script lang="ts">
  import { Record } from "@dfinity/candid/lib/cjs/idl";
  import AssignPlayerToTeam from "../components/AssignPlayerToTeam.svelte";
  import CreatePlayer from "../components/CreatePlayer.svelte";
  import CreateTeam from "../components/CreateTeam.svelte";
  import TempInitialize from "../components/TempInitialize.svelte";
  import { teamStore } from "../stores/TeamStore";
  import ScheduleSeason from "../components/ScheduleSeason.svelte";
  import TeamGrid from "../components/TeamGrid.svelte";
  import LastAndCurrentMatchGroups from "../components/LastAndCurrentMatchGroups.svelte";
  import { scheduleStore } from "../stores/ScheduleStore";
  import { SeasonStatus } from "../models/Season";

  $: teams = $teamStore;
  let seasonStatus: SeasonStatus;

  scheduleStore.subscribeStatus((status) => {
    seasonStatus = status;
  });
</script>

<div class="content">
  {#if teams.length === 0}
    <TempInitialize />
  {:else}
    <div>
      <h1>Teams</h1>
      <TeamGrid />
    </div>

    {#if seasonStatus}
      {#if "notStarted" in seasonStatus}
        <div>
          <h1>Schedule Season</h1>
          <ScheduleSeason />
        </div>
      {:else if "completed" in seasonStatus}
        Season Complete
      {:else}
        <LastAndCurrentMatchGroups />
      {/if}
    {/if}
  {/if}
  <hr style="margin-top: 400px;" />

  <div>
    <h1>Create Team</h1>
    <CreateTeam />
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
