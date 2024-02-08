<script lang="ts">
  import ScheduleSeason from "../components/season/ScheduleSeason.svelte";
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
