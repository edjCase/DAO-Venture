<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import Icon from "./Icon.svelte";

  export let size: "xs" | "sm" | "md" | "lg" | "xl";

  $: currentGame = $currentGameStore;

  const getValue = (value: bigint | undefined): string =>
    value === undefined ? "" : value.toString();

  let character: CharacterWithMetaData | undefined;
  $: {
    if (currentGame !== undefined) {
      if ("notStarted" in currentGame.state) {
        character = undefined;
      } else if ("voting" in currentGame.state) {
        character = undefined;
      } else if ("inProgress" in currentGame.state) {
        character = currentGame.state.inProgress.character;
      } else {
        character = currentGame.state.completed.character;
      }
    }
  }

  $: goldStat = getValue(character?.gold);
  $: healthStat = getValue(character?.health);
  $: maxHealthStat = getValue(character?.maxHealth);
  $: attackStat = getValue(character?.attack);
  $: defenseStat = getValue(character?.defense);
  $: speedStat = getValue(character?.speed);
  $: magicStat = getValue(character?.magic);
</script>

{#if character === undefined}
  <div>Character not found</div>
{:else}
  <div class="flex justify-around">
    <div><Icon kind={{ gold: null }} /> {goldStat}</div>
    <div><Icon kind={{ health: null }} /> {healthStat}/{maxHealthStat}</div>
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
