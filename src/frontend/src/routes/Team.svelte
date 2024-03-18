<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import TeamPage from "../components/team/TeamPage.svelte";
  import { TeamWithId } from "../ic-agent/declarations/league";

  export let teamIdString: string;

  let team: TeamWithId | undefined;
  teamStore.subscribe((teams) => {
    team = teams.find((t) => t.id.toString() === teamIdString);
  });
</script>

{#if team}
  <TeamPage {team} />
{/if}
