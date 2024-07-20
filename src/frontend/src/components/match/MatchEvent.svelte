<script lang="ts">
  import { MatchEvent, TownId } from "../../ic-agent/declarations/main";
  import { playerStore } from "../../stores/PlayerStore";
  import { townStore } from "../../stores/TownStore";

  export let event: MatchEvent;
  export let town1Id: bigint;
  export let town2Id: bigint;

  $: players = $playerStore;
  $: towns = $townStore;

  const variantKeyToString = (trait: any): string => {
    return Object.keys(trait)[0];
  };
  const getPlayerName = (playerId: number): string => {
    return players?.find((p) => p.id === playerId)?.name ?? "Unknown";
  };
  const getTownId = (townId: TownId): bigint => {
    return "town1" in townId ? town1Id : town2Id;
  };
  const getTownName = (townId: TownId): string => {
    let townIdId = getTownId(townId);
    return towns?.find((p) => p.id == townIdId)?.name ?? "Unknown";
  };
</script>

{#if "traitTrigger" in event}
  <div>
    {getPlayerName(event.traitTrigger.playerId)} triggered trait '{variantKeyToString(
      event.traitTrigger.id,
    )}': {event.traitTrigger.description}
  </div>
{:else if "anomolyTrigger" in event}
  <div>
    Aura '{variantKeyToString(event.anomolyTrigger.id)}' triggered: {event
      .anomolyTrigger.description}
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
    {getPlayerName(event.injury.playerId)} got injured
  </div>
{:else if "death" in event}
  <div>Player '{getPlayerName(event.death.playerId)}' died</div>
{:else if "score" in event}
  <div>
    {getTownName(event.score.townId)} scored {event.score.amount} points!
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
