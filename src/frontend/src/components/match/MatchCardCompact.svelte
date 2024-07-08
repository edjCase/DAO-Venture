<script lang="ts">
  import { MatchGroupPredictionSummary } from "../../ic-agent/declarations/main";
  import { MatchDetails } from "../../models/Match";
  import { mapTeamOrUndetermined, TeamOrUndetermined } from "../../models/Team";
  import { LiveMatch } from "../../stores/LiveMatchGroupStore";
  import { predictionStore } from "../../stores/PredictionsStore";
  import { teamStore } from "../../stores/TeamStore";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetails;
  export let liveMatch: LiveMatch | undefined;
  export let selected: boolean = false;

  let predictions: MatchGroupPredictionSummary | undefined;
  predictionStore.subscribeToMatchGroup(match.matchGroupId, (p) => {
    predictions = p;
  });

  $: teams = $teamStore;

  let team1: TeamOrUndetermined | undefined;
  let team2: TeamOrUndetermined | undefined;
  $: {
    if (teams !== undefined) {
      team1 = mapTeamOrUndetermined(match.team1, teams);
      team2 = mapTeamOrUndetermined(match.team2, teams);
    }
  }
  let team1Score: bigint | undefined;
  let team2Score: bigint | undefined;
  $: {
    if (liveMatch) {
      team1Score = liveMatch.team1.score;
      team2Score = liveMatch.team2.score;
    } else {
      team1Score = "score" in match.team1 ? match.team1.score : undefined;
      team2Score = "score" in match.team2 ? match.team2.score : undefined;
    }
  }
  $: borderColor = selected ? "border-green-500" : "border-gray-800";
  $: winner = liveMatch?.winner || match.winner;
  $: prediction =
    predictions === undefined
      ? undefined
      : predictions.matches[Number(match.id)].yourVote.length < 1
        ? undefined
        : predictions.matches[Number(match.id)].yourVote[0];
</script>

{#if team1 && team2}
  <div
    class="bg-gray-700 text-gray-200 p-2 border rounded-lg w-full {borderColor}"
  >
    <MatchCardHeader
      {team1}
      {team2}
      {winner}
      {prediction}
      {team1Score}
      {team2Score}
    >
      {#if match.state == "Error"}
        <div>Bad state:</div>
      {/if}
    </MatchCardHeader>
  </div>
{/if}
