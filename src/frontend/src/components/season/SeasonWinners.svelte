<script lang="ts">
  import { Principal } from "@dfinity/principal";
  import { CompletedSeason, CompletedSeasonTeam } from "../../models/Season";

  export let completedSeason: CompletedSeason;

  let getTeam = (teamId: Principal): CompletedSeasonTeam => {
    let team = completedSeason.teams.find(
      (team) => team.id.compareTo(teamId) == "eq"
    );
    if (!team) throw new Error(`Team ${teamId} not found`); // TODO
    return team;
  };

  let championTeam = getTeam(completedSeason.championTeamId);
  let runnerUpTeam = getTeam(completedSeason.runnerUpTeamId);
</script>

<div class="flex flex-col items-center space-y-4">
  <div
    class="text-6xl text-center flex flex-col items-center bg-gray-800 p-4 rounded-lg shadow-lg"
  >
    {championTeam.name}
    <img class="h-64 w-64" src={championTeam.logoUrl} alt={championTeam.name} />
    <div class="text-4xl mt-4">👑 Season Champions 👑</div>
  </div>
  <div
    class="text-sm text-center flex flex-col items-center bg-gray-500 p-2 rounded-lg shadow-lg"
  >
    {runnerUpTeam.name}
    <img class="h-12 w-12" src={runnerUpTeam.logoUrl} alt={runnerUpTeam.name} />
    <div>🥈 Runner-up 🥈</div>
  </div>
</div>
