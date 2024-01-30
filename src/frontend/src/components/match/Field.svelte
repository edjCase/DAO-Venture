<script lang="ts">
  import { PlayerState } from "../../ic-agent/Stadium";
  import { FieldPositionEnum } from "../../models/FieldPosition";
  import { TeamPositions } from "../../models/Season";
  import { LiveMatch, LiveMatchState } from "../../stores/LiveMatchGroupStore";
  import FieldPlayer from "./FieldPlayer.svelte";
  import FieldBase from "./FieldBase.svelte";
  import { BaseEnum } from "../../models/Base";
  import { TeamDetails } from "../../models/Match";

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
    fieldPositions: TeamPositions;
    offenseTeam: TeamDetails;
    defenseTeam: TeamDetails;
  };

  let liveData: LiveData | undefined;
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
    liveData = {
      match: match.liveState,
      fieldPositions: offenseTeam.positions,
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
      <!-- Home base -->
      <FieldBase
        x={45}
        y={80}
        player={getPlayer(liveData.match.bases.atBat)}
        base={BaseEnum.HomeBase}
      />

      <!-- First base -->
      <FieldBase
        x={70}
        y={55}
        player={getPlayerOrNull(liveData.match.bases.firstBase)}
        base={BaseEnum.FirstBase}
      />

      <FieldPlayer
        x={80}
        y={55}
        player={getPlayer(liveData.fieldPositions.firstBase)}
        position={FieldPositionEnum.FirstBase}
      />

      <!-- Second base -->
      <FieldBase
        x={45}
        y={30}
        player={getPlayerOrNull(liveData.match.bases.secondBase)}
        base={BaseEnum.SecondBase}
      />

      <FieldPlayer
        x={55}
        y={30}
        player={getPlayer(liveData.fieldPositions.secondBase)}
        position={FieldPositionEnum.SecondBase}
      />

      <!-- Short stop -->
      <FieldPlayer
        x={30}
        y={40}
        player={getPlayer(liveData.fieldPositions.shortStop)}
        position={FieldPositionEnum.ShortStop}
      />

      <!-- Third base -->
      <FieldBase
        x={20}
        y={55}
        player={getPlayerOrNull(liveData.match.bases.thirdBase)}
        base={BaseEnum.ThirdBase}
      />

      <FieldPlayer
        x={10}
        y={55}
        player={getPlayer(liveData.fieldPositions.thirdBase)}
        position={FieldPositionEnum.ThirdBase}
      />

      <!-- Pitcher -->
      <FieldPlayer
        x={45}
        y={55}
        player={getPlayer(liveData.fieldPositions.pitcher)}
        position={FieldPositionEnum.Pitcher}
      />

      <!-- Outfield -->
      <FieldPlayer
        x={5}
        y={10}
        player={getPlayer(liveData.fieldPositions.leftField)}
        position={FieldPositionEnum.LeftField}
      />
      <FieldPlayer
        x={45}
        y={0}
        player={getPlayer(liveData.fieldPositions.centerField)}
        position={FieldPositionEnum.CenterField}
      />
      <FieldPlayer
        x={85}
        y={10}
        player={getPlayer(liveData.fieldPositions.rightField)}
        position={FieldPositionEnum.RightField}
      />
    </svg>
  </div>
{/if}

<style>
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
