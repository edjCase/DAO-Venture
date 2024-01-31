<script lang="ts">
  import { LiveTeamDetails } from "../../stores/LiveMatchGroupStore";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let team: LiveTeamDetails;
  export let isOffense: boolean;
</script>

<div class="flex justify-between">
  <div class="flex-1 flex justify-center">Text</div>
  <div class="flex-1 flex flex-col items-center">
    <TeamLogo {team} size="md" borderColor={team.color} />
    <div class="flex justify-center">
      {isOffense ? "Offense" : "Defense"}
    </div>
  </div>
  <div class="flex-1 flex justify-center">Score: {team.score}</div>
</div>
