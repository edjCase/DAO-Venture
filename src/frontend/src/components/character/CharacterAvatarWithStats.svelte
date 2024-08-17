<script lang="ts">
  import { CharacterState } from "../../ic-agent/declarations/main";
  import { gameStateStore } from "../../stores/GameStateStore";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";

  export let size: "xs" | "sm" | "md" | "lg" | "xl";

  $: gameState = $gameStateStore;

  const getValue = (value: bigint | undefined): string =>
    value === undefined ? "" : value.toString();

  let character: CharacterState | undefined;
  $: {
    if (gameState !== undefined) {
      if ("notInitialized" in gameState) {
        character = undefined;
      } else if ("notStarted" in gameState) {
        character = undefined;
      } else if ("inProgress" in gameState) {
        character = gameState.inProgress.character;
      } else {
        character = gameState.completed.character;
      }
    }
  }

  $: goldStat = getValue(character?.gold);
  $: healthStat = getValue(character?.health);
  $: attackStat = getValue(character?.stats.attack);
  $: defenseStat = getValue(character?.stats.defense);
  $: speedStat = getValue(character?.stats.speed);
  $: magicStat = getValue(character?.stats.magic);
</script>

{#if character === undefined}
  <div>Character not found</div>
{:else}
  <div class="flex justify-around">
    <div>🪙 {goldStat}</div>
    <div>🫀 {healthStat}</div>
  </div>
  <div class="flex justify-center m-2">
    <CharacterAvatar {size} characterClass="warrior" seed={0} />
  </div>
  <div class="flex justify-around">
    <div>⚔️ {attackStat}</div>
    <div>🛡️ {defenseStat}</div>
    <div>🏃 {speedStat}</div>
    <div>🔮 {magicStat}</div>
  </div>
{/if}
