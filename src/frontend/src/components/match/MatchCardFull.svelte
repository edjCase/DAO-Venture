<script lang="ts">
  import { MatchDetails } from "../../models/Match";
  import { TurnLog } from "../../models/Season";

  import {
    LiveMatch,
    LiveMatchGroup,
    liveMatchGroupStore,
  } from "../../stores/LiveMatchGroupStore";
  import Field from "./Field.svelte";
  import MatchEvent from "./MatchEvent.svelte";

  export let match: MatchDetails;

  let liveMatch: LiveMatch | undefined;
  let turn: TurnLog | undefined;

  $: {
    const liveMatchGroup: LiveMatchGroup | undefined = $liveMatchGroupStore;
    if (liveMatchGroup && liveMatchGroup.id == Number(match.matchGroupId)) {
      liveMatch = liveMatchGroup.matches[Number(match.id)];
      if (match.team1 && match.team2) {
        match.team1.score = liveMatch?.team1.score;
        match.team2.score = liveMatch?.team2.score;
      }
      if (liveMatch && liveMatch.log.rounds.length > 0) {
        let currentRound =
          liveMatch.log.rounds[liveMatch.log.rounds.length - 1];
        turn = currentRound.turns[currentRound.turns.length - 1];
      }
    }
  }
</script>

<div class="card">
  {#if liveMatch && !!liveMatch.liveState}
    <Field match={liveMatch} />
  {/if}
</div>

<div class="footer">
  {#if turn && match.team1 && match.team2}
    {#each turn.events as e}
      <MatchEvent event={e} team1Id={match.team1.id} team2Id={match.team2.id} />
    {/each}
  {/if}
</div>

<style>
</style>
