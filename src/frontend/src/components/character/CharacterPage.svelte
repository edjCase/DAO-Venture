<script lang="ts">
    import { gameStateStore } from "../../stores/GameStateStore";

    $: gameState = $gameStateStore;
</script>

{#if gameState === undefined}
    <div>No Active Game</div>
{:else}
    <div>Character</div>
    <div>Gold: {gameState.character.gold}</div>
    <div>Health: {gameState.character.health}</div>
    <div>Items:</div>
    <ul>
        {#each gameState.character.items as item}
            <li>{item.name} - {item.description}</li>
        {/each}
    </ul>
    <div>Traits:</div>
    <ul>
        {#each gameState.character.traits as trait}
            <li>{trait.name} - {trait.description}</li>
        {/each}
    </ul>
{/if}
