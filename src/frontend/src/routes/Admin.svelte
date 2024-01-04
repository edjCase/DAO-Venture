<script lang="ts">
  import AssignPlayerToTeam from "../components/AssignPlayerToTeam.svelte";
  import CreatePlayer from "../components/CreatePlayer.svelte";
  import CreateTeam from "../components/CreateTeam.svelte";
  import ScheduleSeason from "../components/ScheduleSeason.svelte";
  import TempInitialize from "../components/TempInitialize.svelte";
  import UpdateLeagueCanistersButton from "../components/UpdateLeagueCanistersButton.svelte";
  import { teamStore } from "../stores/TeamStore";

  $: teams = $teamStore;
</script>

{#if teams.length == 0}
  <TempInitialize />
{/if}
<div>
  <UpdateLeagueCanistersButton />
</div>
---
<div>
  <ScheduleSeason />
</div>
---
<div>
  <h1>Create Team</h1>
  <CreateTeam />
</div>
---
<div>
  <h1>Create Player</h1>
  <CreatePlayer />
</div>
---
<div>
  <h1>Assign Player to Team</h1>
  <AssignPlayerToTeam />
</div>
