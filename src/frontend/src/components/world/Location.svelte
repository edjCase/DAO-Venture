<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";

    export let locationId: bigint;

    $: world = $worldStore;
    $: location = world?.locations.find((l) => l.id == locationId);
</script>

{#if location !== undefined}
    {#if "scenario" in location.kind}
        <g>
            <circle
                cx="0"
                cy="-0.25em"
                r="1.5em"
                fill="black"
                stroke="rgb(156, 163, 175)"
                stroke-width="0.2em"
            />
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
    {:else if "unexplored" in location.kind}
        <text
            x="0"
            y="0"
            dominant-baseline="middle"
            text-anchor="middle"
            font-size="2em"
        >
        </text>
    {:else}
        <text
            x="0"
            y="0"
            dominant-baseline="middle"
            text-anchor="middle"
            font-size="2em"
        >
            ???
        </text>
    {/if}
{/if}
