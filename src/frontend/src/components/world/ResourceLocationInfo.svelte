<script lang="ts">
    import {
        ResourceRarity,
        ResourceKind,
    } from "../../ic-agent/declarations/main";
    import { toJsonString } from "../../utils/StringUtil";
    import ResourceIcon from "../icons/ResourceIcon.svelte";

    export let kind: ResourceKind;
    export let rarity: ResourceRarity;

    let rarityText: string = "";
    $: {
        if ("common" in rarity) {
            rarityText = "Common";
        } else if ("uncommon" in rarity) {
            rarityText = "Uncommon";
        } else if ("rare" in rarity) {
            rarityText = "Rare";
        } else {
            rarityText = "NOT IMPLEMENTED RARITY: " + toJsonString(rarity);
        }
    }
</script>

<div
    class="flex items-center justify-center border border-gray-700 rounded p-2 min-w-24"
>
    <div class="text-md">
        <ResourceIcon {kind} />
    </div>
    <span class="flex items-center gap-1">
        Rarity: {rarityText}
    </span>
</div>
