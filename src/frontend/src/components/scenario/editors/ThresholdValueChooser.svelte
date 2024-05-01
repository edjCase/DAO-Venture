<script lang="ts">
    import { Select } from "flowbite-svelte";
    import ThresholdValueEditor from "./ThresholdValueEditor.svelte";

    export let value:
        | { fixed: bigint }
        | { weightedChance: [bigint, bigint][] };
    let selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "fixed") {
            value = {
                fixed: BigInt(1),
            };
        } else if (selectedType === "weightedChance") {
            value = {
                weightedChance: [[BigInt(1), BigInt(1)]],
            };
        } else {
            throw new Error(`Unknown threshold value type: ${selectedType}`);
        }
    };

    const types = [
        {
            name: "Fixed",
            value: "fixed",
        },
        {
            name: "Weighted Chance",
            value: "weightedChance",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />

<ThresholdValueEditor bind:value />
