<script lang="ts">
  import type { PlayerInfoWithId } from "../ic-agent/PlayerLedger";
  import type { MatchTeam } from "../ic-agent/Stadium";
  import { playerStore } from "../stores/PlayerStore";

  export let teamInfo: MatchTeam;

  type PlayerMatchStats = {
    id: number;
    name: string;
    position: string;
    runs: number;
    hits: number;
  };

  let players: PlayerMatchStats[];
  if (teamInfo.config.length > 0) {
    let config = teamInfo.config[0];
    let unorderedPlayers = [
      extractPlayerInfo(config.catcher, "Catcher"),
      extractPlayerInfo(config.pitcher, "Pitcher"),
      extractPlayerInfo(config.firstBase, "First Base"),
      extractPlayerInfo(config.secondBase, "Second Base"),
      extractPlayerInfo(config.thirdBase, "Third Base"),
      extractPlayerInfo(config.shortStop, "Short Stop"),
      extractPlayerInfo(config.leftField, "Left Field"),
      extractPlayerInfo(config.centerField, "Center Field"),
      extractPlayerInfo(config.rightField, "Right Field"),
    ];
    // Order by the batting order
    players = [];
    for (let playerId of config.battingOrder) {
      const player = unorderedPlayers.find((p) => p.id === playerId);
      players.push(player);
    }
  } else {
    players = [];
  }

  function extractPlayerInfo(
    playerId: number,
    position: string
  ): PlayerMatchStats {
    return {
      id: playerId,
      name: $playerStore.find((p) => p.id === playerId).name,
      position: position,
      runs: 0,
      hits: 0,
    };
  }
</script>

<div class="grid-container">
  <div class="grid-item header">Name</div>
  <div class="grid-item header">Position</div>
  <div class="grid-item header">Runs</div>
  <div class="grid-item header">Hits</div>

  {#each players as player (player.id)}
    <div class="grid-item">{player.name}</div>
    <div class="grid-item">{player.position}</div>
    <div class="grid-item">{player.runs}</div>
    <div class="grid-item">{player.hits}</div>
  {/each}
</div>

<style>
  .grid-container {
    display: grid;
    grid-template-columns: repeat(4, 1fr); /* 4 columns for the 4 headers */
    gap: 0;
    margin: 0 auto;
    width: 80%;
  }
  .grid-item {
    padding: 10px;
    text-align: center;
    border-bottom: 1px solid #888;
    border-right: 1px solid #888; /* Add right border */
  }
  .grid-item.header {
    font-weight: bold;
    background-color: var(--primary-color);
    color: var(--text-color);
    border-top: 1px solid #888; /* Add top border */
    border-left: 1px solid #888; /* Add left border */
  }
</style>
