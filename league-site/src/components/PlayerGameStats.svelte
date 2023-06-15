<script lang="ts">
    import type { TeamGameSnapshot } from "../types/Game";
    export let teamInfo : TeamGameSnapshot;
</script>


<div class="grid-container">
  <div class="grid-item header">Name</div>
  <div class="grid-item header">Position</div>
  <div class="grid-item header">Runs</div>
  <div class="grid-item header">Hits</div>
  <div class="grid-item header">Errors</div>

  {#each teamInfo.players as player (player.name)}
    <div class="grid-item">{player.name}</div>
    <div class="grid-item">{player.position}</div>
    <div class="grid-item">{player.gameStats?.runs}</div>
    <div class="grid-item">{player.gameStats?.hits}</div>
    <div class="grid-item">{player.gameStats?.errors}</div>
  {/each}
</div>


<style >
  .grid-container {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 0;
    margin: 0 auto;
    width: 80%;
  }
  .grid-item {
    padding: 10px;
    text-align: center;
    border-bottom: 1px solid #888;
  }
  .grid-item.header {
    font-weight: bold;
    background-color: var(--primary-color);
    color: var(--text-color);
    border: 1px solid #888;
  }
</style>