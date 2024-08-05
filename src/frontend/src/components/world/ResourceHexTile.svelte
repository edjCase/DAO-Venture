<script lang="ts">
    import {
        LocationKind,
        ResourceKind,
    } from "../../ic-agent/declarations/main";
    import ResourceIcon from "../icons/ResourceIcon.svelte";

    export let kind: LocationKind;

    let toPercentText = (value: number) => {
        return `${(value * 100).toFixed(1)}%`;
    };

    let resource: {
        kind: ResourceKind;
        label: "Efficiency" | "Units";
        value: string;
    };
    $: {
        if ("gold" in kind) {
            resource = {
                kind: { gold: null },
                label: "Efficiency",
                value: toPercentText(kind.gold.efficiency),
            };
        } else if ("wood" in kind) {
            resource = {
                kind: { wood: null },
                label: "Units",
                value: kind.wood.amount.toString(),
            };
        } else if ("stone" in kind) {
            resource = {
                kind: { stone: null },
                label: "Efficiency",
                value: toPercentText(kind.stone.efficiency),
            };
        } else if ("food" in kind) {
            resource = {
                kind: { food: null },
                label: "Units",
                value: kind.food.amount.toString(),
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
            {resource.label}
        </span>
    </span>
</div>
