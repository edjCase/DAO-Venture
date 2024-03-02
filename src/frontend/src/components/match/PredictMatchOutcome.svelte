<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { MatchDetails } from "../../models/Match";
  import { leagueAgentFactory } from "../../ic-agent/declarations/league";
  import TeamLogo from "../team/TeamLogo.svelte";
  import { predictionStore } from "../../stores/PredictionsStore";
  import { TeamId } from "../../models/Team";

  export let match: MatchDetails;

  type MatchPrediction = {
    team1Total: number;
    team1Percentage: number;
    team2Total: number;
    team2Percentage: number;
    yourVote: TeamId | undefined;
  };

  let matchPredictions: MatchPrediction | undefined;

  predictionStore.subscribe((predictions) => {
    if (!predictions) {
      matchPredictions = undefined;
      predictionStore.refetch();
    } else {
      let matchPrediction = predictions[match.id];
      let totalPredictions =
        Number(matchPrediction.team1) + Number(matchPrediction.team2);
      matchPredictions = {
        team1Total: Number(matchPrediction.team1),
        team1Percentage: Number(matchPrediction.team1) / totalPredictions || 0,
        team2Total: Number(matchPrediction.team2),
        team2Percentage: Number(matchPrediction.team2) / totalPredictions || 0,
        yourVote:
          matchPrediction.yourVote.length > 0
            ? matchPrediction.yourVote[0]
            : undefined,
      };
    }
  });

  let predict = function (team: TeamId | undefined) {
    if (!matchPredictions) {
      return;
    }
    matchPredictions.yourVote = team;
    leagueAgentFactory()
      .predictMatchOutcome({
        matchId: match.id,
        winner: team ? [team] : [],
      })
      .then((result) => {
        if ("ok" in result) {
          console.log("Predicted for match: ", match.id);
          predictionStore.refetch();
        } else {
          console.log("Failed to predict for match: ", match.id, result);
        }
      });
  };
</script>

{#if matchPredictions && "id" in match.team1 && "id" in match.team2}
  <div class="flex flex-row items-center mb-10 gap-5">
    <div>
      <div class="text-center">Abstain</div>
      <Button
        checked={!matchPredictions.yourVote}
        on:click={() => predict(undefined)}
      >
        <div class="w-12 h-12">?</div>
      </Button>
    </div>
    <div>
      <div class="text-center">
        {match.team1.name} ({matchPredictions.team1Percentage * 100}% - {matchPredictions.team1Total})
      </div>
      <Button
        checked={matchPredictions.yourVote &&
          "team1" in matchPredictions.yourVote}
        on:click={() => predict({ team1: null })}
      >
        <TeamLogo team={match.team1} size="lg" borderColor={undefined} />
      </Button>
    </div>
    <div>VS</div>
    <div>
      <div class="text-center">
        {match.team2.name} ({matchPredictions.team2Percentage * 100}% - {matchPredictions.team2Total})
      </div>
      <Button
        checked={matchPredictions.yourVote &&
          "team2" in matchPredictions.yourVote}
        on:click={() => predict({ team2: null })}
      >
        <TeamLogo team={match.team2} size="lg" borderColor={undefined} />
      </Button>
    </div>
  </div>
{/if}
