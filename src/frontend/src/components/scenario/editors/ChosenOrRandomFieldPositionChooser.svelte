<script lang="ts">
    import { Select } from "flowbite-svelte";
    import {
        ChosenOrRandomFieldPosition,
        FieldPosition,
    } from "../../../ic-agent/declarations/league";
    import FieldPositionChooser from "./FieldPositionChooser.svelte";

    export let value: ChosenOrRandomFieldPosition;

    let position: FieldPosition = { pitcher: null };

    $: selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "random") {
            value = {
                random: null,
            };
        } else if (selectedType === "chosen") {
            value = {
                chosen: position,
            };
        } else {
            throw new Error(`Unknown effect type: ${selectedType}`);
        }
    };

    const types = [
        {
            name: "Random",
            value: "random",
        },
        {
            name: "Chosen",
            value: "chosen",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />
{#if selectedType === "chosen"}
    <FieldPositionChooser bind:value={position} />
{/if}
