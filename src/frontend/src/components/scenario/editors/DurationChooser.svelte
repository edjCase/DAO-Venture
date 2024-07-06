<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { Duration } from "../../../ic-agent/declarations/main";
    import DurationEditor from "./DurationEditor.svelte";

    export let value: Duration;
    let selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "matches") {
            value = {
                matches: BigInt(1),
            };
        } else if (selectedType === "indefinite") {
            value = {
                indefinite: null,
            };
        } else {
            throw new Error(`Unknown duration type: ${selectedType}`);
        }
    };

    const types = [
        {
            name: "Matches",
            value: "matches",
        },
        {
            name: "Indefinite",
            value: "indefinite",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />

<DurationEditor bind:value />
