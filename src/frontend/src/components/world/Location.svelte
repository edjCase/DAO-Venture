<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import ResourceIcon from "../icons/ResourceIcon.svelte";

    export let locationId: bigint;

    $: world = $worldStore;
    $: location = world?.locations.find((l) => l.id == locationId);

    let rarityColor: string = "";
    $: {
        if (location !== undefined && "resource" in location.kind) {
            if ("common" in location.kind.resource.rarity) {
                rarityColor = "rgb(156, 163, 175)";
            } else if ("uncommon" in location.kind.resource.rarity) {
                rarityColor = "rgb(0, 255, 0)";
            } else if ("rare" in location.kind.resource.rarity) {
                rarityColor = "rgb(255, 0, 0)";
            } else {
                rarityColor = "";
            }
        }
    }

    $: exploring = false; // TODO
</script>

{#if location !== undefined}
    {#if "town" in location.kind}
        <div></div>
    {:else if "resource" in location.kind}
        <g>
            <circle
                cx="0"
                cy="-0.25em"
                r="1.5em"
                fill="black"
                stroke={rarityColor}
                stroke-width="0.2em"
            />
            <text
                x="0"
                y="0"
                dominant-baseline="middle"
                text-anchor="middle"
                font-size="2em"
            >
                <ResourceIcon kind={location.kind.resource.kind} />
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
            {#if exploring}
                🧭
            {/if}
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
