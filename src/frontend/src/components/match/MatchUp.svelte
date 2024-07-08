<script lang="ts">
  import { Team } from "../../ic-agent/declarations/main";
  import { MatchDetails } from "../../models/Match";
  import MatchUpTeam from "./MatchUpTeam.svelte";

  export let match: MatchDetails;
  export let teams: Team[];
</script>

<div class="bg-gray-700 rounded-lg p-4">
  <div class="flex flex-col gap-2">
    <MatchUpTeam {match} teamId={{ team1: null }} {teams} />
    <div class="text-xs text-center">VS</div>
    <MatchUpTeam {match} teamId={{ team2: null }} {teams} />
  </div>
</div>
