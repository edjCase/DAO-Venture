<script lang="ts">
    import {
        LocationKind,
        ResourceKind,
    } from "../../ic-agent/declarations/main";
    import ResourceIcon from "../icons/ResourceIcon.svelte";

    export let kind: LocationKind;

    let resource: {
        kind: ResourceKind;
        type: "efficiency" | "amount";
        value: number | bigint;
    };
    $: {
        if ("gold" in kind) {
            resource = {
                kind: { gold: null },
                type: "efficiency",
                value: kind.gold.efficiency,
            };
        } else if ("wood" in kind) {
            resource = {
                kind: { wood: null },
                type: "amount",
                value: kind.wood.amount,
            };
        } else if ("stone" in kind) {
            resource = {
                kind: { stone: null },
                type: "efficiency",
                value: kind.stone.efficiency,
            };
        } else if ("food" in kind) {
            resource = {
                kind: { food: null },
                type: "amount",
                value: kind.food.amount,
            };
        } else {
            console.error("Unknown resource kind:", kind);
        }
    }
</script>

<div
    class="flex items-center justify-center border border-gray-700 rounded p-2 min-w-24"
>
    <div class="text-md">
        <ResourceIcon kind={resource.kind} />
    </div>
    <span class="flex items-center gap-1">
        {resource.value}
        <span class="text-xs">
            {#if resource.type === "efficiency"}
                Efficeincy
            {:else if resource.type === "amount"}
                Units
            {/if}
        </span>
    </span>
</div>
