<script lang="ts">
  import { LiveTeamDetails } from "../../stores/LiveMatchGroupStore";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let team: LiveTeamDetails;
  export let isOffense: boolean;
</script>

<div
  class="flex justify-between p-5 border border-gray-300 border-opacity-50 {!isOffense
    ? 'border-b-0 rounded-t'
    : 'border-t-0 rounded-b'}"
>
  <div class="flex-1 flex flex-col text-2xl items-center justify-center">
    <div class="flex justify-center font-bold underline">
      {isOffense ? "Offense" : "Defense"}
    </div>
    <div class="text-center">
      {team.name}
    </div>
  </div>
  <div class="flex-1 flex items-center justify-center">
    <TeamLogo {team} size="md" />
  </div>
  <div class="flex-1 flex text-7xl items-center justify-center">
    {team.score}
  </div>
</div>
