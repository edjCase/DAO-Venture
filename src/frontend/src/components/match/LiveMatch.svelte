<script lang="ts">
  import { TurnLog } from "../../ic-agent/declarations/stadium";
  import { MatchDetails } from "../../models/Match";

  import { LiveMatch, LiveTeamDetails } from "../../stores/LiveMatchGroupStore";
  import Field from "./Field.svelte";
  import MatchEvent from "./MatchEvent.svelte";
  import TeamFieldInfo from "./TeamFieldInfo.svelte";

  export let match: MatchDetails;
  export let liveMatch: LiveMatch;

  let lastTurn: TurnLog = {
    events: [],
  };
  let offenseTeam: LiveTeamDetails | undefined;
  let defenseTeam: LiveTeamDetails | undefined;
  let winner: string | undefined;

  $: {
    if ("score" in match.team1 && "score" in match.team2) {
      match.team1.score = liveMatch.team1.score;
      match.team2.score = liveMatch.team2.score;
    }
    if (liveMatch) {
      match.winner = liveMatch.winner;
    }
    if (match.winner && "name" in match.team1 && "name" in match.team2) {
      if ("team1" in match.winner) {
        winner = match.team1.name;
      } else if ("team2" in match.winner) {
        winner = match.team2.name;
      } else {
        winner = "Tie";
      }
    }
    if (liveMatch.log && liveMatch.log.rounds.length > 0) {
      let currentRound = liveMatch.log.rounds[liveMatch.log.rounds.length - 1];
      lastTurn = currentRound.turns[currentRound.turns.length - 1];
    }
    if (liveMatch.liveState) {
      if ("team1" in liveMatch.liveState.offenseTeamId) {
        offenseTeam = liveMatch.team1;
        defenseTeam = liveMatch.team2;
      } else if ("team2" in liveMatch.liveState.offenseTeamId) {
        offenseTeam = liveMatch.team2;
        defenseTeam = liveMatch.team1;
      }
    }
  }
</script>

<div>
  <div>
    {#if liveMatch && !!liveMatch.liveState}
      <div class="text-center text-3xl mb-5">
        Round {liveMatch.log?.rounds.length}
      </div>
      <div class="absolute top-[300px] left-[5%]">
        {#if "id" in match.team1 && "id" in match.team2}
          {#each lastTurn.events as e}
            <MatchEvent
              event={e}
              team1Id={match.team1.id}
              team2Id={match.team2.id}
            />
          {/each}
        {/if}
      </div>
      {#if defenseTeam}
        <TeamFieldInfo team={defenseTeam} isOffense={false} />
      {/if}
      <Field match={liveMatch} />
      {#if offenseTeam}
        <TeamFieldInfo team={offenseTeam} isOffense={true} />
      {/if}
    {:else if winner}
      <div class="text-center text-3xl mb-5">
        Winner: {winner}
      </div>
    {:else}
      <div class="text-center text-3xl mb-5">No Live</div>
    {/if}
  </div>
</div>

<style>
</style>
