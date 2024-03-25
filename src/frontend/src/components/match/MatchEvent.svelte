<script lang="ts">
  import { Event, TeamId } from "../../ic-agent/declarations/stadium";
  import { playerStore } from "../../stores/PlayerStore";
  import { teamStore } from "../../stores/TeamStore";

  export let event: Event;
  export let team1Id: bigint;
  export let team2Id: bigint;

  $: players = $playerStore;
  $: teams = $teamStore;

  const variantKeyToString = (trait: any): string => {
    return Object.keys(trait)[0];
  };
  const getPlayerName = (playerId: number): string => {
    return players?.find((p) => p.id === playerId)?.name ?? "Unknown";
  };
  const getTeamId = (teamId: TeamId): bigint => {
    return "team1" in teamId ? team1Id : team2Id;
  };
  const getTeamName = (teamId: TeamId): string => {
    let teamIdId = getTeamId(teamId);
    return teams?.find((p) => p.id == teamIdId)?.name ?? "Unknown";
  };
</script>

{#if "traitTrigger" in event}
  <div>
    {getPlayerName(event.traitTrigger.playerId)} triggered trait '{variantKeyToString(
      event.traitTrigger.id,
    )}': {event.traitTrigger.description}
  </div>
{:else if "auraTrigger" in event}
  <div>
    Aura '{variantKeyToString(event.auraTrigger.id)}' triggered: {event
      .auraTrigger.description}
  </div>
{:else if "pitch" in event}
  <div>
    {getPlayerName(event.pitch.pitcherId)} pitched
  </div>
{:else if "swing" in event}
  <div>
    {getPlayerName(event.swing.playerId)} swung the bat and {variantKeyToString(
      event.swing.outcome,
    )}
  </div>
{:else if "catch" in event}
  <div>
    {getPlayerName(event.catch.playerId)} caught the ball
  </div>
{:else if "newRound" in event}
  <div>Round Over</div>
{:else if "injury" in event}
  <div>
    {getPlayerName(event.injury.playerId)} got injured: {variantKeyToString(
      event.injury.injury,
    )}
  </div>
{:else if "death" in event}
  <div>Player '{getPlayerName(event.death.playerId)}' died</div>
{:else if "score" in event}
  <div>
    {getTeamName(event.score.teamId)} scored {event.score.amount} points!
  </div>
{:else if "newBatter" in event}
  <div>
    {getPlayerName(event.newBatter.playerId)} is the new batter
  </div>
{:else if "out" in event}
  <div>
    {getPlayerName(event.out.playerId)} got out: {variantKeyToString(
      event.out.reason,
    )}
  </div>
{:else if "matchEnd" in event}
  <div>Match ended: {variantKeyToString(event.matchEnd.reason)}</div>
{:else if "safeAtBase" in event}
  <div>
    {getPlayerName(event.safeAtBase.playerId)} is safe at base '{variantKeyToString(
      event.safeAtBase.base,
    )}'
  </div>
{:else if "hitByBall" in event}
  <div>
    {getPlayerName(event.hitByBall.playerId)} got hit by {getPlayerName(
      event.hitByBall.playerId,
    )}
  </div>
{/if}
