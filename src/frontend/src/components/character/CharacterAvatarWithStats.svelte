<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import { gameStateStore } from "../../stores/GameStateStore";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import Icon from "./Icon.svelte";

  export let size: "xs" | "sm" | "md" | "lg" | "xl";

  $: gameState = $gameStateStore;

  const getValue = (value: bigint | undefined): string =>
    value === undefined ? "" : value.toString();

  let character: CharacterWithMetaData | undefined;
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
    <div><Icon kind={{ gold: null }} /> {goldStat}</div>
    <div><Icon kind={{ health: null }} /> {healthStat}</div>
  </div>
  <div class="flex justify-center m-2">
    <CharacterAvatar {size} characterClass="warrior" seed={0} />
  </div>
  <div class="flex justify-around">
    <div><Icon kind={{ attack: null }} /> {attackStat}</div>
    <div><Icon kind={{ defense: null }} /> {defenseStat}</div>
    <div><Icon kind={{ speed: null }} /> {speedStat}</div>
    <div><Icon kind={{ magic: null }} /> {magicStat}</div>
  </div>
{/if}
