<script lang="ts">
  import {
    CharacterWithMetaData,
    GameWithMetaData,
  } from "../../ic-agent/declarations/main";
  import CharacterInventory from "../character/CharacterInventory.svelte";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  export let game: GameWithMetaData;

  let character: CharacterWithMetaData | undefined;
  $: {
    if ("inProgress" in game.state) {
      character = game.state.inProgress.character;
    } else if ("completed" in game.state) {
      if ("forfeit" in game.state.completed.outcome) {
        character = game.state.completed.outcome.forfeit.character[0];
      } else if ("victory" in game.state.completed.outcome) {
        character = game.state.completed.outcome.victory.character;
      } else if ("death" in game.state.completed.outcome) {
        character = game.state.completed.outcome.death.character;
      } else {
        character = undefined;
      }
    } else {
      character = undefined;
    }
  }
</script>

<div class="flex justify-between">
  <div class="flex justify-around flex-grow">
    {#if character !== undefined}
      <div class="min-w-60">
        <CharacterAvatarWithStats {character} pixelSize={2} tooltips={true} />
      </div>
      <div class="flex flex-col items-center justify-center">
        Items
        <CharacterInventory value={character.inventorySlots} />
      </div>
    {/if}
  </div>
</div>
<slot />
