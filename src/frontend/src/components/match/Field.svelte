<script lang="ts">
  import { BaseState, PlayerState } from "../../ic-agent/Stadium";
  import { FieldPositionEnum } from "../../models/FieldPosition";
  import {
    LiveMatch,
    LiveMatchState,
    LiveTeamDetails,
  } from "../../stores/LiveMatchGroupStore";
  import FieldPlayer from "./FieldPlayer.svelte";
  import FieldBase from "./FieldBase.svelte";
  import { BaseEnum } from "../../models/Base";
  import FieldBall from "./FieldBall.svelte";
  import { FieldPosition } from "../../ic-agent/PlayerLedger";
  import { toJsonString } from "../../utils/JsonUtil";
  import { PlayerId } from "../../models/Player";

  export let match: LiveMatch;

  let getPlayerOrNull = (playerId: [number] | []): PlayerState | undefined => {
    if (playerId.length == 0) return undefined;
    let id = playerId[0];
    return match.liveState?.players.find((p) => p.id == id) || undefined;
  };

  let getPlayer = (playerId: number): PlayerState => {
    let playerOrNull = getPlayerOrNull([playerId]);
    if (!playerOrNull) {
      throw new Error("Player not found");
    }
    return playerOrNull;
  };

  type LiveData = {
    match: LiveMatchState;
    offenseTeam: LiveTeamDetails;
    defenseTeam: LiveTeamDetails;
  };

  const pitcherPosition = { x: 45, y: 60 };
  const firstBasePosition = { x: 85, y: 50 };
  const secondBasePosition = { x: 60, y: 25 };
  const thirdBasePosition = { x: 5, y: 50 };
  const homeBasePosition = { x: 45, y: 80 };
  const shortStopPosition = { x: 25, y: 30 };
  const centerFieldPosition = { x: 45, y: 0 };
  const leftFieldPosition = { x: 5, y: 10 };
  const rightFieldPosition = { x: 85, y: 10 };

  const homeBaseLocation = { x: 45, y: 80 };
  const firstBaseLocation = { x: 70, y: 45 };
  const secondBaseLocation = { x: 45, y: 20 };
  const thirdBaseLocation = { x: 20, y: 45 };

  let liveData: LiveData | undefined;

  let ballLocations: { x: number; y: number }[] = [];

  let getPositionCoordinates = (
    position: FieldPosition
  ): { x: number; y: number } => {
    if ("firstBase" in position) {
      return firstBasePosition;
    } else if ("secondBase" in position) {
      return secondBasePosition;
    } else if ("thirdBase" in position) {
      return thirdBasePosition;
    } else if ("homeBase" in position) {
      return homeBasePosition;
    } else if ("shortStop" in position) {
      return shortStopPosition;
    } else if ("centerField" in position) {
      return centerFieldPosition;
    } else if ("leftField" in position) {
      return leftFieldPosition;
    } else if ("rightField" in position) {
      return rightFieldPosition;
    } else if ("pitcher" in position) {
      return pitcherPosition;
    }
    throw new Error("Invalid position: " + toJsonString(position));
  };

  let getPlayerBaseCoordinates = (
    playerId: PlayerId,
    bases: BaseState
  ): { x: number; y: number } => {
    if (playerId == bases.atBat) {
      return homeBaseLocation;
    } else if (bases.firstBase.length > 0 && playerId == bases.firstBase[0]) {
      return firstBaseLocation;
    } else if (bases.secondBase.length > 0 && playerId == bases.secondBase[0]) {
      return secondBaseLocation;
    } else if (bases.thirdBase.length > 0 && playerId == bases.thirdBase[0]) {
      return thirdBaseLocation;
    }
    throw new Error("Player not found on a base: " + playerId);
  };

  $: if (match.liveState) {
    let offenseTeam;
    let defenseTeam;
    if ("team1" in match.liveState.offenseTeamId) {
      offenseTeam = match.team1;
      defenseTeam = match.team2;
    } else {
      offenseTeam = match.team2;
      defenseTeam = match.team1;
    }
    ballLocations = [homeBaseLocation];
    if (match.log && match.log.rounds.length > 0) {
      let currentRound = match.log.rounds[match.log.rounds.length - 1];
      let lastTurn = currentRound.turns[currentRound.turns.length - 1];
      if (lastTurn.events.length > 0) {
        let swingEvent = lastTurn.events.find((e: any) => "swing" in e); // TODO how to return swing
        if (swingEvent && "swing" in swingEvent) {
          if ("foul" in swingEvent.swing.outcome) {
            ballLocations.push({ x: 100, y: 110 });
          } else if ("hit" in swingEvent.swing.outcome) {
            if ("stands" in swingEvent.swing.outcome.hit) {
              // Homerun
              ballLocations.push({ x: 45, y: -5 });
            } else {
              let ballLocation = getPositionCoordinates(
                swingEvent.swing.outcome.hit
              );
              ballLocations.push(ballLocation);

              let throwEvent = lastTurn.events.find((e) => "throw_" in e); // TODO how to return throw_
              if (throwEvent && "throw_" in throwEvent) {
                let position = getPlayerBaseCoordinates(
                  throwEvent.throw_.to,
                  match.liveState.bases
                );
                // TODO slightly miss if the hitByBall doesn't exist
                ballLocations.push(position);
              }
            }
          } else {
            // Strike
            ballLocations.push({ x: 45, y: 110 });
          }
        }
      }
    }
    liveData = {
      match: match.liveState,
      offenseTeam: offenseTeam,
      defenseTeam: defenseTeam,
    };
  } else {
    liveData = undefined;
  }
</script>

{#if liveData}
  <div class="field">
    <svg
      class="field-svg"
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
    >
      <rect width="100%" height="100%" fill="#F5F5F5" opacity={0.1} />

      <!-- Outfield -->
      <FieldPlayer
        x={leftFieldPosition.x}
        y={leftFieldPosition.y}
        teamColor={liveData.defenseTeam.color}
        player={getPlayer(liveData.defenseTeam.positions.leftField)}
        position={FieldPositionEnum.LeftField}
      />
      <FieldPlayer
        x={centerFieldPosition.x}
        y={centerFieldPosition.y}
        teamColor={liveData.defenseTeam.color}
        player={getPlayer(liveData.defenseTeam.positions.centerField)}
        position={FieldPositionEnum.CenterField}
      />
      <FieldPlayer
        x={rightFieldPosition.x}
        y={rightFieldPosition.y}
        teamColor={liveData.defenseTeam.color}
        player={getPlayer(liveData.defenseTeam.positions.rightField)}
        position={FieldPositionEnum.RightField}
      />

      <!-- Home base -->
      <FieldBase
        x={homeBaseLocation.x}
        y={homeBaseLocation.y}
        teamColor={liveData.offenseTeam.color}
        player={getPlayer(liveData.match.bases.atBat)}
        base={BaseEnum.HomeBase}
      />

      <!-- First base -->
      <FieldBase
        x={firstBaseLocation.x}
        y={firstBaseLocation.y}
        teamColor={liveData.offenseTeam.color}
        player={getPlayerOrNull(liveData.match.bases.firstBase)}
        base={BaseEnum.FirstBase}
      />

      <FieldPlayer
        x={firstBasePosition.x}
        y={firstBasePosition.y}
        teamColor={liveData.defenseTeam.color}
        player={getPlayer(liveData.defenseTeam.positions.firstBase)}
        position={FieldPositionEnum.FirstBase}
      />

      <!-- Second base -->
      <FieldBase
        x={secondBaseLocation.x}
        y={secondBaseLocation.y}
        teamColor={liveData.offenseTeam.color}
        player={getPlayerOrNull(liveData.match.bases.secondBase)}
        base={BaseEnum.SecondBase}
      />

      <FieldPlayer
        x={secondBasePosition.x}
        y={secondBasePosition.y}
        teamColor={liveData.defenseTeam.color}
        player={getPlayer(liveData.defenseTeam.positions.secondBase)}
        position={FieldPositionEnum.SecondBase}
      />

      <!-- Short stop -->
      <FieldPlayer
        x={shortStopPosition.x}
        y={shortStopPosition.y}
        teamColor={liveData.defenseTeam.color}
        player={getPlayer(liveData.defenseTeam.positions.shortStop)}
        position={FieldPositionEnum.ShortStop}
      />

      <!-- Third base -->
      <FieldBase
        x={thirdBaseLocation.x}
        y={thirdBaseLocation.y}
        teamColor={liveData.offenseTeam.color}
        player={getPlayerOrNull(liveData.match.bases.thirdBase)}
        base={BaseEnum.ThirdBase}
      />

      <FieldPlayer
        x={thirdBasePosition.x}
        y={thirdBasePosition.y}
        teamColor={liveData.defenseTeam.color}
        player={getPlayer(liveData.defenseTeam.positions.thirdBase)}
        position={FieldPositionEnum.ThirdBase}
      />

      <!-- Pitcher -->
      <FieldPlayer
        x={pitcherPosition.x}
        y={pitcherPosition.y}
        teamColor={liveData.defenseTeam.color}
        player={getPlayer(liveData.defenseTeam.positions.pitcher)}
        position={FieldPositionEnum.Pitcher}
      />

      <!-- Baseball -->
      <FieldBall origin={pitcherPosition} locations={ballLocations} />

      <!-- Text -->
      <text x={60} y={88} font-size={3}>
        Strikes: {liveData.match.strikes}
      </text>
      <text x={60} y={93} font-size={3}>
        Outs: {liveData.match.outs}
      </text>
    </svg>
  </div>
{/if}

<style>
  text {
    fill: var(--color-text);
  }
  .field {
    position: relative;
    width: 100%;
    height: 100%;
  }
  .field-svg {
    margin: auto;
    width: 100vw;
    height: 100vw;
    max-width: 500px;
    max-height: 500px;
  }
</style>
