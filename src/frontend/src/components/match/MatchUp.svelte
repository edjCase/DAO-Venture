<script lang="ts">
  import { MatchDetails } from "../../models/Match";
  import MatchUpTeam from "./MatchUpTeam.svelte";

  export let match: MatchDetails;
</script>

<div class="bg-gray-700 rounded-lg p-4">
  <div class="flex flex-col gap-2">
    <MatchUpTeam {match} teamId={{ team1: null }} />
    <MatchUpTeam {match} teamId={{ team2: null }} />
  </div>
</div>
