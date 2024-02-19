<script lang="ts">
  import { MatchDetails } from "../../models/Match";
  import { LiveMatch } from "../../stores/LiveMatchGroupStore";
  import { predictionStore } from "../../stores/PredictionsStore";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetails;
  export let liveMatch: LiveMatch | undefined;
  export let selected: boolean = false;

  $: predictions = $predictionStore;

  $: team1 = liveMatch?.team1 == undefined ? match.team1 : liveMatch.team1;
  $: team2 = liveMatch?.team2 == undefined ? match.team2 : liveMatch.team2;
  $: borderColor = selected ? "border-green-500" : "border-gray-800";
  $: winner = liveMatch?.winner || match.winner;
  $: prediction =
    predictions === undefined ? undefined : predictions[match.id].yourVote;
</script>

<div
  class="bg-gray-800 text-gray-200 p-2 border rounded-lg w-full {borderColor}"
>
  <MatchCardHeader {team1} {team2} {winner} {prediction}>
    {#if match.state == "Error"}
      <div>Bad state:</div>
    {/if}
  </MatchCardHeader>
</div>
