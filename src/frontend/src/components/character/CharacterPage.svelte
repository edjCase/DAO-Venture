<script lang="ts">
  import { gameStateStore } from "../../stores/GameStateStore";

  $: gameState = $gameStateStore;
</script>

{#if gameState === undefined}
  <div>No Active Game</div>
{:else}
  <div class="text-center text-3xl p-6">
    <div class="mb-5 w-full">
      <div>Items:</div>
      <div class="border p-6">
        <ul class="text-md">
          {#each gameState.character.items as item}
            <li>{item.name} - {item.description}</li>
          {/each}
        </ul>
      </div>
    </div>
    <div class="mb-5 w-full">
      <div>Traits:</div>
      <div class="border p-6">
        <ul class="text-md">
          {#each gameState.character.traits as trait}
            <li>{trait.name} - {trait.description}</li>
          {/each}
        </ul>
      </div>
    </div>
  </div>
{/if}
