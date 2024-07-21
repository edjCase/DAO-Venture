<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { RangeRequirement } from "../../../ic-agent/declarations/main";
    import RequirementRangeEditor from "./RequirementRangeEditor.svelte";

    export let value: RangeRequirement;
    let selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "fixed") {
            value = {
                above: BigInt(1),
            };
        } else if (selectedType === "weightedChance") {
            value = {
                below: BigInt(1),
            };
        } else {
            throw new Error(`Unknown range requirement type: ${selectedType}`);
        }
    };

    const types = [
        {
            name: "Above",
            value: "above",
        },
        {
            name: "Below",
            value: "weightedChance",
        },
    ];
</script>

}

<Select items={types} on:change={onChange} value={selectedType} />

<RequirementRangeEditor bind:value />
