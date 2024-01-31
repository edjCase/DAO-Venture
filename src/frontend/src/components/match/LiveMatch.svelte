<script lang="ts">
  import { MatchDetails } from "../../models/Match";
  import { TurnLog } from "../../models/Season";

  import {
    LiveMatch,
    LiveMatchGroup,
    LiveTeamDetails,
    liveMatchGroupStore,
  } from "../../stores/LiveMatchGroupStore";
  import Field from "./Field.svelte";
  import MatchEvent from "./MatchEvent.svelte";
  import TeamFieldInfo from "./TeamFieldInfo.svelte";

  export let match: MatchDetails;

  let liveMatch:
    | {
        info: LiveMatch;
        lastTurn: TurnLog;
        offenseTeam: LiveTeamDetails | undefined;
        defenseTeam: LiveTeamDetails | undefined;
      }
    | undefined;

  $: {
    const liveMatchGroup: LiveMatchGroup | undefined = $liveMatchGroupStore;
    if (liveMatchGroup && liveMatchGroup.id == Number(match.matchGroupId)) {
      let info = liveMatchGroup.matches[Number(match.id)];
      if (match.team1 && match.team2) {
        match.team1.score = info.team1.score;
        match.team2.score = info.team2.score;
      }
      let lastTurn: TurnLog;
      if (info.log.rounds.length > 0) {
        let currentRound = info.log.rounds[info.log.rounds.length - 1];
        lastTurn = currentRound.turns[currentRound.turns.length - 1];
      } else {
        lastTurn = {
          events: [],
        };
      }
      let offenseTeam: LiveTeamDetails | undefined;
      let defenseTeam: LiveTeamDetails | undefined;
      if (info.liveState) {
        if ("team1" in info.liveState.offenseTeamId) {
          offenseTeam = info.team1;
          defenseTeam = info.team2;
        } else if ("team2" in info.liveState.offenseTeamId) {
          offenseTeam = info.team2;
          defenseTeam = info.team1;
        }
      }
      liveMatch = {
        info,
        lastTurn: lastTurn,
        offenseTeam: offenseTeam,
        defenseTeam: defenseTeam,
      };
    }
  }
</script>

<div>
  <div>
    {#if liveMatch && !!liveMatch.info.liveState}
      {#if liveMatch.defenseTeam}
        <TeamFieldInfo team={liveMatch.defenseTeam} isOffense={false} />
      {/if}
      <Field match={liveMatch.info} />
      {#if liveMatch.offenseTeam}
        <TeamFieldInfo team={liveMatch.offenseTeam} isOffense={true} />
      {/if}
    {/if}
  </div>

  <div>
    {#if liveMatch?.lastTurn && match.team1 && match.team2}
      {#each liveMatch?.lastTurn.events as e}
        <MatchEvent
          event={e}
          team1Id={match.team1.id}
          team2Id={match.team2.id}
        />
      {/each}
    {/if}
  </div>
</div>

<style>
</style>
