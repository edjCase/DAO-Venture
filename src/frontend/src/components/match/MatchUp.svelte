<script lang="ts">
  import { MatchDetails, TeamDetailsOrUndetermined } from "../../models/Match";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let match: MatchDetails;

  let getTeamName = (team: TeamDetailsOrUndetermined) => {
    if ("name" in team) {
      return team.name;
    }
    return "Undetermined"; // TODO
  };

  // Placeholder function for getting team stats
  let getTeamStats = (_: TeamDetailsOrUndetermined) => {
    return "(4-3)";
  };
</script>

<div class="matchup-card bg-gray-700 rounded-lg p-4">
  <div class="flex items-center justify-center justify-evently mb-4">
    <div class="flex flex-col items-center">
      <span class="team-name font-semibold block mb-2">
        {getTeamName(match.team1)}
      </span>
      <TeamLogo team={match.team1} size="md" borderColor={undefined} />
      <span class="team-stats text-sm mt-2">
        {getTeamStats(match.team1)}
      </span>
    </div>
    <span class="text-xl font-bold my-4">VS</span>
    <div class="flex flex-col items-center">
      <span class="team-name font-semibold block mb-2">
        {getTeamName(match.team2)}
      </span>
      <TeamLogo team={match.team2} size="md" borderColor={undefined} />
      <span class="team-stats text-sm mt-2">
        {getTeamStats(match.team2)}
      </span>
    </div>
  </div>
  <!-- Prediction Selection -->
  <div class="prediction-selection text-center">
    <button
      class="predict-btn bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-lg mr-2"
      data-team="team1">Predict {getTeamName(match.team1)}</button
    >
    <button
      class="predict-btn bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-lg"
      data-team="team2">Predict {getTeamName(match.team2)}</button
    >
  </div>
</div>
