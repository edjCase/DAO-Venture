<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { MatchDetails } from "../../models/Match";
  import { predictionStore } from "../../stores/PredictionsStore";
  import { TeamId } from "../../ic-agent/declarations/league";
  import { leagueAgentFactory } from "../../ic-agent/League";

  export let match: MatchDetails;
  export let teamId: TeamId;

  type MatchPrediction = {
    teamTotal: number;
    teamPercentage: number;
    yourVote: TeamId | undefined;
  };

  let matchPredictions: MatchPrediction | undefined;

  predictionStore.subscribeToMatchGroup(match.matchGroupId, (predictions) => {
    if (!predictions) {
      matchPredictions = undefined;
      predictionStore.refetchMatchGroup(match.matchGroupId);
    } else {
      let matchPrediction = predictions.matches[Number(match.id)];
      let totalPredictions =
        Number(matchPrediction.team1) + Number(matchPrediction.team2);
      let team =
        "team1" in teamId ? matchPrediction.team1 : matchPrediction.team2;
      matchPredictions = {
        teamTotal: Number(team),
        teamPercentage: Number(team) / totalPredictions || 0,
        yourVote:
          matchPrediction.yourVote.length > 0
            ? matchPrediction.yourVote[0]
            : undefined,
      };
    }
  });

  let predict = async function (team: TeamId | undefined) {
    if (!matchPredictions) {
      return;
    }
    let leagueAgent = await leagueAgentFactory();
    let result = await leagueAgent.predictMatchOutcome({
      matchId: match.id,
      winner: team ? [team] : [],
    });
    if ("ok" in result) {
      console.log("Predicted for match: ", match.id);
      predictionStore.refetchMatchGroup(match.matchGroupId);
    } else {
      console.log("Failed to predict for match: ", match.id, result);
    }
  };
</script>

{#if matchPredictions && "id" in match.team1 && "id" in match.team2}
  <div>
    <div class="text-center">
      <div>
        ({matchPredictions.teamPercentage * 100}% - {matchPredictions.teamTotal})
      </div>
    </div>
    {#if matchPredictions.yourVote === undefined}
      <Button on:click={() => predict(teamId)}>
        Predict {"team1" in teamId ? match.team1.name : match.team2.name}
      </Button>
    {/if}
  </div>
{/if}
