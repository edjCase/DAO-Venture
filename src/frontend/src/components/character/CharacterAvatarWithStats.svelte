<script lang="ts">
  import { gameStateStore } from "../../stores/GameStateStore";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";

  export let size: "xs" | "sm" | "md" | "lg" | "xl";

  $: gameState = $gameStateStore;

  const getValue = (value: bigint | undefined): string =>
    value === undefined ? "" : value.toString();

  $: goldStat = getValue(gameState?.character.gold);
  $: healthStat = getValue(gameState?.character.health);
  $: attackStat = getValue(gameState?.character.stats.attack);
  $: defenseStat = getValue(gameState?.character.stats.defense);
  $: speedStat = getValue(gameState?.character.stats.speed);
  $: magicStat = getValue(gameState?.character.stats.magic);
</script>

<div class="flex justify-around">
  <div>🪙 {goldStat}</div>
  <div>🫀 {healthStat}</div>
</div>
<div class="flex justify-center m-2">
  <CharacterAvatar {size} characterClass="archer" seed={0} />
</div>
<div class="flex justify-around">
  <div>⚔️ {attackStat}</div>
  <div>🛡️ {defenseStat}</div>
  <div>🏃 {speedStat}</div>
  <div>🔮 {magicStat}</div>
</div>
