<script lang="ts">
    import { gameStateStore } from "../../stores/GameStateStore";

    export let locationId: bigint;

    $: gameState = $gameStateStore;
    $: location = gameState?.locations.find((l) => l.id == locationId);

    $: hasCharacter = gameState?.characterLocationId == locationId;
</script>

{#if location !== undefined}
    <g>
        {#if hasCharacter}
            <circle
                cx="0"
                cy="-0.25em"
                r="1.5em"
                fill="black"
                stroke="rgb(156, 163, 175)"
                stroke-width="0.2em"
            />
        {/if}
        <text
            x="0"
            y="0"
            dominant-baseline="middle"
            text-anchor="middle"
            font-size="2em"
        >
            🏰
        </text>
    </g>
{/if}
