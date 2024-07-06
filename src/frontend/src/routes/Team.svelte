<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import TeamPage from "../components/team/TeamPage.svelte";
  import { Team } from "../ic-agent/declarations/main";

  export let teamIdString: string;

  let team: Team | undefined;
  teamStore.subscribe((teams) => {
    team = teams?.find((t) => t.id.toString() === teamIdString);
  });
</script>

{#if team}
  <TeamPage {team} />
{/if}
