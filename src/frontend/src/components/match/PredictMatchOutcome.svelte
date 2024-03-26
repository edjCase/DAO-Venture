<script lang="ts">
  import { Button, Progressbar } from "flowbite-svelte";
  import { MatchDetails } from "../../models/Match";
  import { predictionStore } from "../../stores/PredictionsStore";
  import { TeamId } from "../../ic-agent/declarations/league";
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

  let predict = async function (team: TeamId) {
    if (!matchPredictions) {
      return;
    }
    await predictionStore.predictMatchOutcome(
      match.matchGroupId,
      match.id,
      team,
    );
  };
</script>

{#if matchPredictions && "id" in match.team1 && "id" in match.team2}
  <div class="w-full">
    <div class="w-full flex items-center justify-center">
      <div class="whitespace-nowrap mr-2">
        🔮 {matchPredictions.teamPercentage * 100}%
      </div>
      <Progressbar
        progress={matchPredictions.teamPercentage * 100}
        labelInside={false}
        size="h-2.5"
        color="green"
      />
    </div>
    {#if matchPredictions.yourVote === undefined}
      <Button on:click={() => predict(teamId)}>
        Predict {"team1" in teamId ? match.team1.name : match.team2.name}
      </Button>
    {/if}
  </div>
{/if}
