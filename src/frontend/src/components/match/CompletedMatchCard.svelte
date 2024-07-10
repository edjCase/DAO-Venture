<script lang="ts" context="module">
  export type TeamStats = {
    totalHits: number;
    totalRuns: number;
    totalHomeRuns: number;
    totalStrikeouts: number;
    totalPitches: number;
    totalStrikes: number;
  };
</script>

<script lang="ts">
  import {
    CompletedMatch,
    MatchGroupPredictionSummary,
    TeamIdOrTie,
  } from "../../ic-agent/declarations/main";
  import { predictionStore } from "../../stores/PredictionsStore";
  import { teamStore } from "../../stores/TeamStore";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let matchGroupId: number;
  export let matchId: number;
  export let match: CompletedMatch;
  export let team1Stats: TeamStats | undefined = undefined;
  export let team2Stats: TeamStats | undefined = undefined;

  let predictions: MatchGroupPredictionSummary | undefined;
  predictionStore.subscribeToMatchGroup(matchGroupId, (p) => {
    predictions = p;
  });

  $: teams = $teamStore;

  $: team1 = teams?.find((t) => t.id == match.team1.id);
  $: team2 = teams?.find((t) => t.id == match.team2.id);

  let team1Score: bigint | undefined;
  let team2Score: bigint | undefined;
  $: {
    team1Score = "score" in match.team1 ? match.team1.score : undefined;
    team2Score = "score" in match.team2 ? match.team2.score : undefined;
  }
  $: prediction =
    predictions?.matches[Number(matchId)] === undefined
      ? undefined
      : predictions.matches[Number(matchId)].yourVote.length < 1
        ? undefined
        : predictions.matches[Number(matchId)].yourVote[0];

  let getTeamEmojis = (
    winner: TeamIdOrTie | undefined,
    teamId: "team1" | "team2",
  ) => {
    let emojis = [];
    if (winner) {
      if (teamId in winner) {
        emojis.push("👑");
      } else if ("tie" in winner) {
        emojis.push("😑");
      }
    }
    if (prediction && teamId in prediction) {
      emojis.push("🔮");
    }
    return emojis.join(" ");
  };

  $: team1Emoji = getTeamEmojis(match.winner, "team1");
  $: team2Emoji = getTeamEmojis(match.winner, "team2");
</script>

{#if team1 && team2}
  <div class="flex justify-between">
    <div class="flex flex-col">
      <div class="flex flex-row items-center">
        <TeamLogo team={team1} size="xs" />
        <div class="text-4xl font-bold mx-4 flex items-center">
          {team1Score || "-"}
          <span class="text-base">{team1Emoji}</span>
        </div>
      </div>
      {#if team1Stats}
        <div class="flex justify-center mt-2">
          <ul class="text-sm">
            <li>Hits: {team1Stats.totalHits}</li>
            <li>Runs: {team1Stats.totalRuns}</li>
            <li>Home Runs: {team1Stats.totalHomeRuns}</li>
            <li>Strikeouts: {team1Stats.totalStrikeouts}</li>
            <li>Pitches: {team1Stats.totalPitches}</li>
            <li>Strikes: {team1Stats.totalStrikes}</li>
          </ul>
        </div>
      {/if}
    </div>
    <div class="flex flex-col items-center justify-around"></div>
    <div class="flex flex-col">
      <div class="flex flex-row items-center justify-end">
        <div class="text-4xl font-bold mx-4 flex items-center">
          <span class="text-base">{team2Emoji}</span>
          {team2Score || "-"}
        </div>
        <TeamLogo team={team2} size="xs" />
      </div>
      {#if team2Stats}
        <div class="flex justify-center mt-2">
          <ul class="text-sm">
            <li>Hits: {team2Stats.totalHits}</li>
            <li>Runs: {team2Stats.totalRuns}</li>
            <li>Home Runs: {team2Stats.totalHomeRuns}</li>
            <li>Strikeouts: {team2Stats.totalStrikeouts}</li>
            <li>Pitches: {team2Stats.totalPitches}</li>
            <li>Strikes: {team2Stats.totalStrikes}</li>
          </ul>
        </div>
      {/if}
    </div>
  </div>
{/if}
