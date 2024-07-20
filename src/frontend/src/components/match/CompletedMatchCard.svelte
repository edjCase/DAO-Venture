<script lang="ts" context="module">
  export type TownStats = {
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
    TownIdOrTie,
  } from "../../ic-agent/declarations/main";
  import { predictionStore } from "../../stores/PredictionsStore";
  import { townStore } from "../../stores/TownStore";
  import TownLogo from "../town/TownLogo.svelte";

  export let matchGroupId: number;
  export let matchId: number;
  export let match: CompletedMatch;
  export let town1Stats: TownStats | undefined = undefined;
  export let town2Stats: TownStats | undefined = undefined;

  let predictions: MatchGroupPredictionSummary | undefined;
  predictionStore.subscribeToMatchGroup(matchGroupId, (p) => {
    predictions = p;
  });

  $: towns = $townStore;

  $: town1 = towns?.find((t) => t.id == match.town1.id);
  $: town2 = towns?.find((t) => t.id == match.town2.id);

  let town1Score: bigint | undefined;
  let town2Score: bigint | undefined;
  $: {
    town1Score = "score" in match.town1 ? match.town1.score : undefined;
    town2Score = "score" in match.town2 ? match.town2.score : undefined;
  }
  $: prediction =
    predictions?.matches[Number(matchId)] === undefined
      ? undefined
      : predictions.matches[Number(matchId)].yourVote.length < 1
        ? undefined
        : predictions.matches[Number(matchId)].yourVote[0];

  let getTownEmojis = (
    winner: TownIdOrTie | undefined,
    townId: "town1" | "town2",
  ) => {
    let emojis = [];
    if (winner) {
      if (townId in winner) {
        emojis.push("👑");
      } else if ("tie" in winner) {
        emojis.push("😑");
      }
    }
    if (prediction && townId in prediction) {
      emojis.push("🔮");
    }
    return emojis.join(" ");
  };

  $: town1Emoji = getTownEmojis(match.winner, "town1");
  $: town2Emoji = getTownEmojis(match.winner, "town2");
</script>

{#if town1 && town2}
  <div class="flex justify-between">
    <div class="flex flex-col">
      <div class="flex flex-row items-center">
        <TownLogo town={town1} size="xs" />
        <div class="text-4xl font-bold mx-4 flex items-center">
          {town1Score || "-"}
          <span class="text-base">{town1Emoji}</span>
        </div>
      </div>
      {#if town1Stats}
        <div class="flex justify-center mt-2">
          <ul class="text-sm">
            <li>Hits: {town1Stats.totalHits}</li>
            <li>Runs: {town1Stats.totalRuns}</li>
            <li>Home Runs: {town1Stats.totalHomeRuns}</li>
            <li>Strikeouts: {town1Stats.totalStrikeouts}</li>
            <li>Pitches: {town1Stats.totalPitches}</li>
            <li>Strikes: {town1Stats.totalStrikes}</li>
          </ul>
        </div>
      {/if}
    </div>
    <div class="flex flex-col items-center justify-around"></div>
    <div class="flex flex-col">
      <div class="flex flex-row items-center justify-end">
        <div class="text-4xl font-bold mx-4 flex items-center">
          <span class="text-base">{town2Emoji}</span>
          {town2Score || "-"}
        </div>
        <TownLogo town={town2} size="xs" />
      </div>
      {#if town2Stats}
        <div class="flex justify-center mt-2">
          <ul class="text-sm">
            <li>Hits: {town2Stats.totalHits}</li>
            <li>Runs: {town2Stats.totalRuns}</li>
            <li>Home Runs: {town2Stats.totalHomeRuns}</li>
            <li>Strikeouts: {town2Stats.totalStrikeouts}</li>
            <li>Pitches: {town2Stats.totalPitches}</li>
            <li>Strikes: {town2Stats.totalStrikes}</li>
          </ul>
        </div>
      {/if}
    </div>
  </div>
{/if}
